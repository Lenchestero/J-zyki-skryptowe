import { Level1 } from './scenes/Level1.js';
import { Death } from './scenes/Death.js';
import { Menu } from './scenes/Menu.js';

const config = {
    type: Phaser.AUTO,
    title: 'Overlord Rising',
    description: '',
    parent: 'game-container',
    width: 1280,
    height: 720,
    physics:{
        default: 'arcade',
        arcade: {
            debug:false,
            gravity: { y: 400}
        }
    },
    pixelArt: true,
    scene: [
        Menu,
        Level1,
        Death
    ],
    scale: {
        mode: Phaser.Scale.FIT,
        autoCenter: Phaser.Scale.CENTER_BOTH
    },
}

new Phaser.Game(config);
            