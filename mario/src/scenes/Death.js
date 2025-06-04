export class Death extends Phaser.Scene {
    constructor(){
        super('Death')
    }

    preload(){
        this.load.image('background', 'assets/background.png');
    }

    create(){
        this.background = this.add.image(640,360,'background');
        this.background.setTint(0xff0000);
        const title=this.add.text(450, 200, 'GAME OVER', {fontFamily: "Tahoma", fontSize: '64px', fill: '#fff' });
        title.setOrigin(0.5);
        title.setPosition(this.cameras.main.centerX, this.cameras.main.centerY - 100);
        this.cursors = this.input.keyboard.createCursorKeys();
        const subtitle=this.add.text(450, 300, 'Press ENTER to restart level', { fontSize: '24px', fill: '#fff', strokeThickness: 1, stroke: '#fff' });
        subtitle.setOrigin(0.5);
        subtitle.setPosition(this.cameras.main.centerX, this.cameras.main.centerY);
        this.enterKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.ENTER);
    }

    update(){
        if(this.enterKey.isDown){
            this.scene.start('Level1');
        }
    }
}