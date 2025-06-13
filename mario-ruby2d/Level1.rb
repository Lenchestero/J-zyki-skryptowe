require 'ruby2d'

set title: "Platform Jumper"
set width: 1280, height: 720

$current_scene = :menu
@background = nil
@texts = []
@platforms= []
@moving_platforms = []
@velocity_y = 0
@gravity = 0.5
@jumping = false
@speed = 4
@keys_held = {}
@coins = []
@coins_collected = 0;
@lifes = 3
@dude_health = 5
@enemies = []
@is_player_added = false

def draw_menu
	clear
	@background = Image.new('assets/background.png', x: 0, y: 0, width: 1280, height: 720)
	title = Text.new(
		"PLATFORM JUMPER",
		x: Window.width / 2, 
		y: Window.height / 2 - 100,
		size: 64,
		color: 'white',
		font: 'assets/Regular.ttf')
	title.x -= title.width / 2
	controls = Text.new(
		"Controls: Arrows to move, space bar to jump, F to attack",
		x: Window.width / 2,
		y: Window.height / 2 - 30,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	controls.x -= controls.width / 2
	subtitle = Text.new(
		"Press ENTER to start game",
		x: Window.width / 2, 
		y: Window.height / 2 + 50,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	subtitle.x -= subtitle.width / 2

	@texts = [title, controls, subtitle]
end

def add_platform(has_enemy:,ismovable:,length:,height:,position:)
	unless ismovable
		length.times do |x|
			unless @is_player_added
				@dude = Sprite.new('assets/spritesheet.png', clip_width: 128, clip_height: 128, x: position + (length * 64)/2, y: height - 130, time: 100, animations: { idle: 25..27, kick: 1..4, jump: 6..12, run: 13..24})
				@is_player_added = true
			end
			h = position + (x*64)
			tile = Image.new('assets/Tile_02.png', x: h, y: height, width: 64, height: 64)
			@platforms << {Image: tile, x: position, y: height, length: length, width: length * 64, height: 64 }
		end
		if has_enemy
			enemy = Sprite.new('assets/spritesheet_enemy.png', clip_width: 64, clip_height: 64, width: 128, height: 128, x: position + (length * 64) / 2, y: height - 78, time: 100, animations: { walk: 1..8, attack: 9..18})
			enemy.play animation: :walk, loop: true
			@enemies << { Image: enemy, direction: 1, health: 5, min_x: position - 10, max_x: position + length *64 + 10, enemy_last_attack: Time.now, is_attacking: false}
		end
	else
		moving_tile= {
			image: Image.new('assets/moving_tile.png', x: position, y: height, width: 256, height: 64),
			speed: 1,
			min_x: position - 200,
			max_x: position + 200,
			direction: 1}
		@moving_platforms << moving_tile
	end
	amount = length/2 
	amount.times do |x|
		h = position + 10 + (x*32) + (x*130)
		coin = Image.new('assets/coin.png', x: h, y: height - 70, width: 40, height: 40)
		@coins << coin
	end
end

def load_level(file_path)
	File.readlines(file_path).each do |line|
    	parts = line.strip.split
    	has_enemy = false
    	ismovable = false
        if parts[0] == "true"
        	has_enemy = true
        end
        if parts[1] == "true"
        	ismovable = true
        end
        length, height, position = parts[2..4].map(&:to_i)
        add_platform(has_enemy: has_enemy, ismovable: ismovable, length: length, height: height, position: position)
   	end
end

def move_enemy
		@enemies.each do |enemy|
			if !enemy[:is_attacking]
				enemy[:Image].x += 1 * enemy[:direction]
				if enemy[:Image].x < enemy[:min_x] || enemy[:Image].x + enemy[:Image].width > enemy[:max_x]
					enemy[:direction] *= -1
					if enemy[:direction] == -1
						enemy[:Image].play animation: :walk, loop: true, flip: :horizontal
					else
						enemy[:Image].play animation: :walk, loop: true
					end
				end
			end
		end 
end

def move_the_platforms
	@moving_platforms.each do |platform|
		platform[:image].x += platform[:speed] * platform[:direction]
		if platform[:image].x >= platform[:max_x] || platform[:image].x <= platform[:min_x]
			platform[:direction] *= -1
		end
	end
end

def collect_coins
	@coins.reject! do |coin|
		if @dude.x < coin.x + coin.width && @dude.x + @dude.width > coin.x && @dude.y < coin.y + coin.height && @dude.y + @dude.height > coin.y
			coin.remove
			@coins_collected += 1
			true
			
		else
			false
		end
	end
end

def enemy_attack
	@enemies.each do |enemy|
		if  @dude.x < enemy[:Image].x + enemy[:Image].width - 100 && @dude.x + @dude.width > enemy[:Image].x + 100 && @dude.y < enemy[:Image].y + enemy[:Image].height && @dude.y + @dude.height > enemy[:Image].y
			enemy[:is_attacking] = true
			if Time.now - enemy[:enemy_last_attack] > 1
				enemy[:Image].play animation: :attack, loop: true
				enemy[:enemy_last_attack] = Time.now
				@dude_health -= 1;
				@health_text.text = "Health: #{@dude_health}"
				@dude.color = [1, 0, 0, 1]
			else
				@dude.color = [1, 1, 1, 1]
			end
		else
			enemy[:is_attacking] = false
		end
	end
end

def attacking
	@enemies.reject! do |enemy|
		if  @dude.x < enemy[:Image].x + enemy[:Image].width - 100 && @dude.x + @dude.width > enemy[:Image].x + 100 && @dude.y < enemy[:Image].y + enemy[:Image].height && @dude.y + @dude.height > enemy[:Image].y
			enemy[:health] -= 1
			opacity = (enemy[:health] + 1 ).to_f/ 4.0
			enemy[:Image].color = [1,1,1,opacity] 
			if enemy[:health] == 0
				enemy[:Image].remove
				@dude.color = [1,1,1,1]
				true
			else
				false
			end
		end
	end
end

def start_game
	clear
	@is_player_added = false
	@platforms.clear
	@moving_platforms.clear
	@coins.clear
	@lifes = 3
	@health = 5
	@enemies.clear
	@coins_collected = 0
	@background = Image.new('assets/background.png', x: 0, y: 0, width: 1280, height: 720)
	@score = Text.new(
		"Score: 0",
		x: 24,
		y: 24,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	@life_text = Text.new(
		"Lifes left: 2",
		x: Window.width/2 - 50,
		y: 20,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	@health_text = Text.new(
		"Health: 5",
		x: 1150,
		y: 20,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	load_level("level.txt")
	@last_attack = Time.now
	@dude.play animation: :idle, loop: true	
	@player_state = :idle
	@dude.width = 128
	@dude.height = 128
	@jumping = false
	velocity_y = 0
	
end

def death
	clear
	@background = Image.new('assets/background.png', x: 0, y: 0, width: 1280, height: 720)
	@background.color = [1, 0, 0, 0.5]
	title = Text.new(
		"You died",
		x: Window.width / 2, 
		y: Window.height / 2 - 100,
		size: 64,
		color: 'white',
		font: 'assets/Regular.ttf')
	title.x -= title.width / 2

	subtitle = Text.new(
		"Press ENTER to restart",
		x: Window.width / 2, 
		y: Window.height / 2 + 50,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	subtitle.x -= subtitle.width / 2
end

def win
	clear
	@background = Image.new('assets/background.png', x: 0, y: 0, width: 1280, height: 720)
	@background.color = [0, 1, 0, 0.5]
	title = Text.new(
		"You won!",
		x: Window.width / 2, 
		y: Window.height / 2 - 100,
		size: 64,
		color: 'white',
		font: 'assets/Regular.ttf')
	title.x -= title.width / 2

	subtitle = Text.new(
		"Press ENTER to restart",
		x: Window.width / 2, 
		y: Window.height / 2 + 50,
		size: 20,
		color: 'white',
		font: 'assets/Regular.ttf')
	subtitle.x -= subtitle.width / 2
end

def player_on_ground?
	@platforms.any? do |platform|
		@dude.x < platform[:x] + platform[:width] - 70 &&
		@dude.x + @dude.width > platform[:x] + 70 &&
		@dude.y + @dude.height <= platform[:y] + 5 &&
		@dude.y + @dude.height >= platform[:y] - 5
	end ||
	@moving_platforms.any? do |platform|
		p = platform[:image]
		@dude.x < p.x + p.width - 70 &&
		@dude.x + @dude.width > p.x + 70 &&
		@dude.y + @dude.height <= p.y + 5 &&
		@dude.y + @dude.height >= p.y - 5
	end
end

on :key_down do |event|
	case $current_scene
		when :menu
		if event.key == "return"
			$current_scene = :level1
			start_game
		end
		when :death
		if event.key == "return"
			$current_scene = :menu
			draw_menu
		end
		when :win
		if event.key == "return"
			$current_scene = :menu
			draw_menu
		end
		when :level1
		@keys_held[event.key] = true
		case event.key
			when 'right'
				@facing_left = false
				@dude.x += @speed
				@dude.play animation: :run, loop: false do
				@dude.play animation: :idle, loop: true
				end
			when 'left'
				@facing_left = true
				@dude.x -= @speed
				@dude.play animation: :run, loop: false, flip: :horizontal do
				@dude.play animation: :idle, loop: true
				end
			when 'f'
				@attacking = true
				@attack_start = Time.now
				if @facing_left == false 
					@dude.play animation: :kick, loop: true do
					@dude.play animation: :idle, loop: true
					end
				else
					@dude.play animation: :kick, loop: true, flip: :horizontal do
					@dude.play animation: :idle, loop: true, flip: :horizontal
					end
				end
			when 'space'
				if player_on_ground?
					@velocity_y = -12
					@jumping = true
					if @facing_left == false
						@dude.play animation: :jump, loop: false do
						@dude.play animation: :idle, loop: true
						end
					else
						@dude.play animation: :jump, loop: false, flip: :horizontal do
						@dude.play animation: :idle, loop: true, flip: :horizontal
						end
					end
				end
		end
	end
end

on :key_up do |event|
	if event.key == 'f'
		@attacking = false
	end
	@keys_held[event.key] = false
end

update do
	if $current_scene == :level1
		if @dude.y > Window.height
			if @lifes == 1
				$current_scene = :death
				death
			else
				@lifes -= 1
				@life_text.text = "Lifes left: #{@lifes - 1}"
				@dude_health = 5
				@health_text.text = "Health: #{@dude_health}"
				@dude.x = 100
				@dude.y = 432
			end
		end
		if @dude_health == 0
			if @lifes == 1
				$current_scene = :death
				death
			else
				@lifes -= 1
				@dude_health = 5
				@health_text.text = "Health: #{@dude_health}"
				@dude.x = 100
				@dude.y = 432
				@dude.color = [1,1,1,1]
			end
		end
		move_the_platforms
		move_enemy
		enemy_attack
		collect_coins
		@score.text = "Score: #{@coins_collected}"
		if @coins.empty?
			$current_scene = :win
			win
		end
		if @keys_held['right']
			@dude.x += @speed
			@facing_left = false
			unless @jumping || @attacking
				@dude.play animation: :run, loop: true
			end
		elsif @keys_held['left']
			@dude.x -= @speed
			@facing_left = true
			unless @jumping || @attacking
				@dude.play animation: :run, loop: true, flip: :horizontal
			end
		else
			if @attacking
				if (Time.now - @last_attack) > 0.3
					attacking
					@last_attack = Time.now
				end
			end
			unless @jumping || @attacking
				@dude.play animation: :idle, loop: true
			end
		end
		@dude.y += @velocity_y
		@velocity_y += @gravity
		on_ground = false
		@platforms.each do |platform|
			puts 
			if @dude.x < platform[:x] + platform[:width] - 70 && @dude.x + @dude.width > platform[:x] + 70 && @dude.y  < platform[:y] + platform[:height] - 25 && @dude.y + @dude.height > platform[:y]
				if @dude.y <= platform[:y]
					@dude.y = platform[:y] - @dude.height
					@velocity_y = 0
					@jumping = false
					on_ground = true
				else
					@velocity_y = 5
				end
			end
		end
		@moving_platforms.each do |platform|
			p = platform[:image]
			if @dude.x < p.x + p.width - 70 && @dude.x + @dude.width > p.x + 70 &&@dude.y < p.y + p.height - 30 && @dude.y + @dude.height > p.y
				if @dude.y + 60 <= p.y 
					@dude.y = p.y - @dude.height
					@velocity_y = 0
					@jumping = false
					on_ground = true
					@dude.x += platform[:speed] * 2 * platform[:direction]
				else
					@velocity_y = 5
				end
			end
		end
		@jumping = !on_ground
	end
end

draw_menu


show