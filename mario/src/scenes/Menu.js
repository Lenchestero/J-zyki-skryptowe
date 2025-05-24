export class Menu extends Phaser.Scene {
    constructor(){
        super('Menu')
    }
    preload(){
        this.load.image('background', 'assets/background.png');
    }

    create(){
        this.background = this.add.image(640,360,'background');
        const title= this.add.text(450, 200, 'PLATFORM JUMPER', { fontFamily: "Tahoma",fontSize: '64px', fill: '#fff' });
        title.setOrigin(0.5);
        title.setPosition(this.cameras.main.centerX, this.cameras.main.centerY - 100);
        this.cursors = this.input.keyboard.createCursorKeys();
        const controls= this.add.text(450, 300, 'Controls: Arrows to move, F to attack', { fontSize: '20px', fill: '#fff' });
        controls.setOrigin(0.5);
        controls.setPosition(this.cameras.main.centerX, this.cameras.main.centerY-50);
        const subtitle= this.add.text(450, 300, 'Press ENTER to start game', { fontSize: '20px', fill: '#fff' });
        subtitle.setOrigin(0.5);
        subtitle.setPosition(this.cameras.main.centerX, this.cameras.main.centerY+50);
        this.enterKey = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.ENTER);
    }

    update(time){
        if(this.enterKey.isDown){
            this.scene.start('Level1');
        }
    }
}