export class Dude extends Phaser.Physics.Arcade.Sprite{
    constructor(scene,x,y){
        super(scene,x,y,'dude_running');
        scene.add.existing(this);
        scene.physics.add.existing(this);
        this.setBounce(0);
        this.setCollideWorldBounds(true);
        this.body.setSize(60, 100).setOffset(32, 30);
        this.jumps = 0;
        this.maxJumps = 2;  
        this.canJump = true;  
        this.lastJumpTime = 0;  
        this.jumpCooldown = 300;  
    }

    make_Animations(){
        this.anims.create({
            key: 'run',
            frames: this.anims.generateFrameNumbers('dude_running', {start: 0, end: 11}),
            frameRate: 10,
            repeat: -1
        })
        this.anims.create({
            key: 'jump',
            frames: this.anims.generateFrameNumbers('dude_jumping', {start: 0, end: 6}),
            frameRate: 10,
            repeat: 0
        })
        this.anims.create({
            key: 'idle',
            frames: this.anims.generateFrameNumbers('idle', {start: 0, end: 2}),
            frameRate: 5,
            repeat: -1
        })

    }

    moveLeft(){
        this.setVelocityX(-160);
        this.anims.play('run', true);
        this.flipX = true;

    }

    moveRight(){
        this.setVelocityX(160);
        this.anims.play('run', true);
        this.flipX = false;
    }

    jump(){
        const currentTime = this.scene.time.now;
        if (this.body.touching.down) {
            this.canJump = true; 
            if (this.canJump) {
                this.setVelocityY(-400); 
                this.anims.play('jump', true);
                this.jumps = 1;
                this.canJump = false;
                this.lastJumpTime = currentTime; 
            }
        } 
        else {
            if (this.jumps < this.maxJumps && currentTime - this.lastJumpTime > this.jumpCooldown) {
                this.setVelocityY(-300);
                this.anims.play('jump', true);
                this.jumps++; 
                this.lastJumpTime = currentTime;
            }
        }
    }

    idle(){
        this.setVelocityX(0);
        this.anims.play('idle', true);
    }
}