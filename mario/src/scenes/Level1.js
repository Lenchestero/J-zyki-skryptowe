import { Dude } from  '../Objects/Dude.js';

export class Level1 extends Phaser.Scene {

    constructor() {
        super('Level1');
        this.coins_collected = 0;
        this.coins_spawned = 0;
    }

    preload(){
        this.load.image('background', 'assets/background.png');
        this.load.image('tile2', 'assets/Tile_02.png');
        this.load.image('tile_move', 'assets/moving_tile.png');
        this.load.image('coin', 'assets/coin.png');
        this.load.spritesheet('dude_running', 'assets/Running.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('dude_jumping', 'assets/Platform Jump.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('idle', 'assets/Upward Jump.png', {frameWidth: 128, frameHeight: 128});
    }

    add_platform(ismovable, length, height, position){
        if(ismovable == false){
            for(let x= 0 ;  x <= length; x++ ){
                let h =position + (x * 32) 
                this.platforms.create(h,height,'tile2').setScale(2).refreshBody();
            }
        }
        else{
            this.movingPlatform = this.physics.add.sprite(position, height, 'tile_move').setScale(2).setOrigin(0.5, 0.5);
            this.movingPlatform.setImmovable(true);
            this.movingPlatform.body.setAllowGravity(false);
            this.platformSpeed = 1;  
            this.platformMinX = 400;  
            this.platformMaxX = 1000;  
            this.platformDirection = 1;
        }
        for (let x= 0; x <= Math.floor(length/2); x++ ) {
            let h =position + (x * 32) + (x*30)
            let coin = this.coin.create(h, height -100, 'coin').setScale(2).refreshBody();
            coin.body.allowGravity = false;
            coin.setImmovable(true);
            this.coins_spawned++;
        }
    }

    create() {

        this.add.image(640,360,'background');
        this.platforms = this.physics.add.staticGroup();
        this.scoreText = this.add.text(16, 16, 'Score: 0', {
            fontSize: '24px',
            fill: '#ffffff'
        });
        this.coin= this.physics.add.group();
        this.add_platform(false, 6, 560 , 20 );
        this.add_platform(false, 7, 500, 300);
        this.add_platform(false, 4, 300 , 100 );
        this.add_platform(false, 3, 500 , 700 );
        this.add_platform(false, 7, 600 , 1000 );
        this.add_platform(true, 7, 200 , 500 );
        this.dude= new Dude(this,100,400);
        this.physics.add.collider(this.dude, this.platforms);
        this.physics.add.collider(this.dude, this.movingPlatform);
        this.cursors = this.input.keyboard.createCursorKeys();
        this.dude.make_Animations();
        this.physics.add.collider(this.coin, this.platforms);
        this.physics.add.overlap(this.dude, this.coin, this.collectItem, null, this);
        
    }   
    
    collectItem(dude, item) {
        item.disableBody(true, true);
        this.coins_collected++;
        this.scoreText.setText('Score: ' + this.coins_collected);
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
        else {
            this.dude.idle();
        }
        this.movingPlatform.x += this.platformSpeed * this.platformDirection;
        if (this.movingPlatform.x >= this.platformMaxX || this.movingPlatform.x <= this.platformMinX) {
            this.platformDirection *= -1;
        }

        if (this.dude.y > 620) {
            this.coins_collected = 0;
            this.scene.start('Death');
        }
        if(this.coins_collected == this.coins_spawned){
            this.coins_collected = 0;
            this.scene.start('Win');
        }
     

    }
}
