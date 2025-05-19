export class Win extends Phaser.Scene {
    constructor(){
        super('Win')
    }

    preload(){
        this.load.image('background', 'assets/background.png');
    }

    create(){
        this.background = this.add.image(640,360,'background');
        this.background.setTint(0x7fbf7f);
        const title=this.add.text(450, 200, 'You won!', {fontFamily: "Tahoma", fontSize: '64px', fill: '#fff' });
        title.setOrigin(0.5);
        title.setPosition(this.cameras.main.centerX, this.cameras.main.centerY - 100);
        this.cursors = this.input.keyboard.createCursorKeys();
        const subtitle=this.add.text(450, 300, 'Press ENTER to go back to menu', { fontSize: '20px', fill: '#fff' });
        subtitle.setOrigin(0.5);
        subtitle.setPosition(this.cameras.main.centerX, this.cameras.main.centerY);
        this.enterKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.ENTER);
    }

    update(time){
        if(this.enterKey.isDown){
            this.scene.start('Menu');
        }
    }
}