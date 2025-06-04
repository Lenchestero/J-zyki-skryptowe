export class Enemy extends Phaser.Physics.Arcade.Sprite{
    constructor(scene,x,y){
        super(scene,x,y,'slime_walk');
        scene.add.existing(this);
        scene.physics.add.existing(this);
        this.setBounce(0);
        this.setCollideWorldBounds(true);
        this.body.setSize(50, 32).setOffset(7, 8);
        this.direction = -1;
        this.isAttacking = false;
        this.health = 4;
    }

    make_Animations(){
        this.anims.create({
            key: 'slime_attack',
            frames: this.anims.generateFrameNumbers('slime_attack', {start: 21, end: 29}),
            frameRate: 10,
            repeat: -1
        })
        this.anims.create({
            key: 'slime_walk',
            frames: this.anims.generateFrameNumbers('slime_walk', {start: 16, end: 23}),
            frameRate: 7,
            repeat: -1
        })
    }
    
    move(x, minX, maxX){
        if (!this.isAttacking) {
            this.anims.play('slime_walk', true);
            this.setVelocityX(this.direction * 50);
            this.flipX = this.direction > 0;
            if (x <= minX) {
                this.direction = 1;
            }
            else if (x >= maxX) {
                this.direction = -1;
            }
        }
    }

    attack(dude){
        if (!this.isAttacking) {
            this.isAttacking = true;
            this.scene.time.delayedCall(300, () => {
                if (!this || !this.body) {
                    return;
                }
                this.setVelocityX(0);
                this.anims.play('slime_attack', true);
                dude.health --;
                dude.setTint(0xff0000);
                this.scene.updatehealth(dude);
                this.scene.time.delayedCall(100, () => {dude.clearTint()});
                this.scene.time.delayedCall(1000, () => {this.isAttacking = false;});
            });  
        }
    }
}