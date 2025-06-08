import { Dude } from  '../Objects/Dude.js';
import { Enemy } from  '../Objects/Enemy.js';

export class Level1 extends Phaser.Scene {

    constructor() {
        super('Level1');
        this.coins_collected = 0;
        this.coins_spawned = 0;
        this.position_x = 0;
        this.position_y = 0;
        this.platforms = null;
        this.moving_platforms = null;
        this.coin = null;
        this.slimes = null;  
    }

    init(data){
        this.isRandom = data.isRandom
    }

    preload(){
        this.load.image('background', 'assets/background.png');
        this.load.image('tile2', 'assets/Tile_02.png');
        this.load.image('tile_move', 'assets/moving_tile.png');
        this.load.image('coin', 'assets/coin.png');
        this.load.spritesheet('dude_running', 'assets/Running.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('dude_jumping', 'assets/Platform Jump.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('dude_attack', 'assets/Kick.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('idle', 'assets/Upward Jump.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('slime_attack', 'assets/Slime1_Attack_full.png', {frameWidth: 64, frameHeight: 64});
        this.load.spritesheet('slime_walk', 'assets/Slime1_Run_body.png', {frameWidth: 64, frameHeight: 64});
        this.load.json("level", "level_maker.json")
    }

    add_platform(ismovable, length, height, position, isEnemy = false){
        if(!ismovable){
            for(let x= 0 ;  x < length; x++ ){
                let h =position + (x * 64) 
                this.platforms.create(h,height,'tile2').setScale(2).setOrigin(0).refreshBody();
            }
            if(isEnemy){
                const slime = new Enemy(this,position + length/2 *32 , height-80).setScale(2);
                slime.make_Animations();
                slime.setData("MinX", position - 25);
                slime.setData("MaxX", position + length * 64 - 75);
                this.slimes.add(slime)
            }
        }
        else{
            const new_platform = this.moving_platforms.create(position, height, 'tile_move').setScale(2).setOrigin(0);
            new_platform.setImmovable(true);
            new_platform.body.setAllowGravity(false); 
            new_platform.setVelocityX(150)
            new_platform.setData("platformMinX", position - 50);
            new_platform.setData("platformMaxX", position + 400);   
        }
        for (let x= 0; x < length; x++ ) {
            let h =position + (x * 64)
            let coin = this.coin.create(h + 16, height - 50, 'coin').setScale(2).setOrigin(0).refreshBody();
            coin.body.allowGravity = false;
            coin.setImmovable(true);
            this.coins_spawned++;
        }
    }

    loading(level, isRandom = false){
        let level_content;
        if(!isRandom){
            level_content = this.cache.json.get(level)
        }
        else{
            level_content = level
        }
        this.platforms = this.physics.add.staticGroup();
        this.moving_platforms = this.physics.add.group()
        this.coin= this.physics.add.group();
        this.slimes= this.physics.add.group();


        let dude_spawn = true

        level_content.platforms.forEach(p =>{
            this.add_platform(p.ismovable, p.length, p.height, p.position, p.isEnemy)
            if(dude_spawn && !p.ismovable){
                this.dude= new Dude(this,p.position + (Math.floor(p.length/2) * 64),p.height - 100);
                this.position_x = this.dude.body.position.x;
                this.position_y = this.dude.body.position.y;
                this.dude.make_Animations();
                dude_spawn = false
            }
        })
        
    }
    slime_attack(player, enemy){
        if(enemy){
            enemy.attack(player);
        }
    }


    randomize(){
        const random_level = {
            platforms: []
        }
        const max_height = this.scale.height - 64
        const max_width = Math.floor(this.scale.width, 64)
        let platform_count = Phaser.Math.Between(8,14)
        let enemy_count = Phaser.Math.Between(2,platform_count/2)
        let movable_platform_count = Phaser.Math.Between(1,3)
        let dude_spawn = false;
        let p_c = platform_count + movable_platform_count
        for(let i=0; i< p_c; i++){
            let height = Math.max(max_height - (Phaser.Math.Between(0,6) * 174), 134);
            if(platform_count > 0){
                let length = Phaser.Math.Between(1,4);
                let position = Phaser.Math.Between(0, max_width - length * 64);
                while (true) {
                    let check = 0
                    for(let x of random_level.platforms){
                        let rectangle = new Phaser.Geom.Rectangle(position, height, length * 64, 64)
                        let rectangle_x = new Phaser.Geom.Rectangle(x.position, x.height, x.length * 64, 64)
                        let z = Phaser.Geom.Intersects.GetRectangleToRectangle(rectangle, rectangle_x)
                        if(z.length > 0){
                            check = 1
                            length = Phaser.Math.Between(1,4);
                            position = Phaser.Math.Between(0, max_width - length * 64);
                            height = Math.max(max_height - (Phaser.Math.Between(0,6) * 174), 134);
                        }
                    }
                    if (check == 0){
                        break;
                    }
                    check = 0;
                }
                
                let isEnemy;
                if(enemy_count > 0 && dude_spawn){
                    isEnemy = true;
                    enemy_count -= 1;
                }
                dude_spawn = true
                platform_count -= 1;
                random_level.platforms.push({ismovable: false, length: length, height: height, position: position, isEnemy: isEnemy})
            }
            else if(movable_platform_count > 0){
                let position = Phaser.Math.Between(0, max_width - 656);
                movable_platform_count -= 1;
                random_level.platforms.push({ismovable: true, length: 5, height: height, position: position, isEnemy: false})
            }
        }
        
        this.loading(random_level, true)
    }

    create() {
        this.physics.world.setBounds(0, -700, 1280, 1700);
        this.add.image(640,360,'background');
        if (!this.isRandom){
            this.loading("level");
        }
        else{
            this.randomize();
        }
       
        this.scoreText = this.add.text(16, 16, 'Score: 0', {
            fontSize: '24px',
            fill: '#ffffff'
        });
        this.healthtext = this.add.text(1100, 16, 'Health: 8', {
            fontSize: '24px',
            fill: '#ffffff'
        });
        this.lifetext = this.add.text(500, 16, 'Lifes left: 2', {
            fontSize: '24px',
            fill: '#ffffff'
        });
        this.physics.add.collider(this.dude, this.platforms);
        this.physics.add.collider(this.slimes, this.platforms);
        this.physics.add.collider(this.dude, this.moving_platforms);
        this.physics.add.collider(this.coin, this.platforms);
        this.physics.add.overlap(this.dude, this.coin, this.collectItem, null, this);
        this.physics.add.overlap(this.dude, this.slimes, this.slime_attack, null, this);
        this.cursors = this.input.keyboard.createCursorKeys();
        this.keyF = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.F);
        
    }   


    player_on_platform(platform){
        if(platform.x > platform.getData("platformMaxX")){
            platform.setVelocityX(-150)
        }
        else if(platform.x < platform.getData("platformMinX")){
            platform.setVelocityX(150)
        }
        if(this.dude.body.blocked.down && platform.body.touching.up){
            this.dude.body.velocity.x += platform.body.velocity.x
        }
    }

    collectItem(dude,item) {
        item.destroy();
        this.coins_collected++;
        this.scoreText.setText('Score: ' + this.coins_collected);
    }

    updatehealth(dude){
        this.healthtext.setText('Health: '+ this.dude.health);
    }
    updateLifes(dude){
        this.lifetext.setText('Lifes left: '+ (this.dude.lifes-1));
    }
    update(){
      
        if (this.cursors.right.isDown){
            this.dude.moveRight();
        }
        else if (this.cursors.left.isDown){
            this.dude.moveLeft();
        }
        else if (this.cursors.up.isDown) {
            this.dude.jump();
        }
        else if(this.keyF.isDown){
            this.dude.attack(this.slimes);
        }
        else {
            this.dude.idle();
        }


        this.moving_platforms.children.iterate(this.player_on_platform,this)
        if(this.slimes && this.slimes.children){
            this.slimes.children.iterate((slime)=>{if (slime) {slime.move(slime.body.position.x, slime.getData("MinX"),slime.getData("MaxX"))}})
        }
        if ((this.dude.y > 720)|| (this.dude.health == 0)) {
            if(this.dude.lifes == 1){
                this.coins_collected = 0;
                this.scene.start('Death');
            }
            else {
                this.dude.x= this.position_x + this.dude.body.width * 2;
                this.dude.y= this.position_y;
                this.dude.setVelocity(0);
                this.dude.health = 8;
                this.dude.lifes --;
                this.updatehealth(this.dude);
                this.updateLifes(this.dude);
            }
            
        }
        if(this.coins_collected == this.coins_spawned){
            this.coins_collected = 0;
            this.scene.start('Win');
        }
     

    }
}
