import { Dude } from  '../Objects/Dude.js';

export class Level1 extends Phaser.Scene {

    constructor() {
        super('Level1');
    }

    preload(){
        this.load.image('background', 'assets/background.png');
        //this.load.image('tile1', 'assets/Tile_01.png');
        this.load.image('tile2', 'assets/Tile_02.png');
        this.load.image('tile_move', 'assets/moving_tile.png');
        //this.load.image('tile3', 'assets/Tile_03.png');
        //this.load.image('tile4', 'assets/Tile_04.png');
        this.load.spritesheet('dude_running', 'assets/Running.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('dude_jumping', 'assets/Platform Jump.png', {frameWidth: 128, frameHeight: 128});
        this.load.spritesheet('idle', 'assets/Upward Jump.png', {frameWidth: 128, frameHeight: 128});
    }

    create() {
        this.add.image(640,360,'background');
        this.platforms = this.physics.add.staticGroup();
        for(let x= 0 ;  x <= 6; x++ ){
            let h =20 + (x * 32) 
            this.platforms.create(h,560,'tile2').setScale(2).refreshBody();
        }
        for(let x= 0 ;  x <= 7; x++ ){
            let h =300 + (x * 32) 
            this.platforms.create(h,500,'tile2').setScale(2).refreshBody();
        }
        for(let x= 0 ;  x <= 4; x++ ){
            let h =100 + (x * 32) 
            this.platforms.create(h,300,'tile2').setScale(2).refreshBody();
        } 
        for(let x= 0 ;  x <= 3; x++ ){
            let h =700 + (x * 32) 
            this.platforms.create(h,500,'tile2').setScale(2).refreshBody();
        } 
          for(let x= 0 ;  x <= 7; x++ ){
            let h =1000 + (x * 32) 
            this.platforms.create(h,600,'tile2').setScale(2).refreshBody();
        }
        this.movingPlatform = this.physics.add.sprite(500, 200, 'tile_move').setScale(2).setOrigin(0.5, 0.5);
        this.movingPlatform.setImmovable(true);
        this.movingPlatform.body.setAllowGravity(false);
        this.platformSpeed = 1;  
        this.platformMinX = 400;  
        this.platformMaxX = 1000;  
        this.platformDirection = 1;
        this.dude= new Dude(this,100,400);
        this.physics.add.collider(this.dude, this.platforms);
        this.physics.add.collider(this.dude, this.movingPlatform);
        this.cursors = this.input.keyboard.createCursorKeys();
        this.dude.make_Animations();
        
    }   
    
    update(time){
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
            this.scene.start('Death');
        }
    }
}
