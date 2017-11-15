package com.senproj.luna.map.blocks;

public abstract class Block {
    private final int DEFAULT_BLOCK_WIDTH = 16, DEFAULT_BLOCK_HEIGHT = 16;

    private float posX, posY, width, height;
    private BlockType type;

    public Block(float posX, float posY, BlockType type) {
        this.posX = posX;
        this.posY = posY;
        this.width = DEFAULT_BLOCK_WIDTH;
        this.height = DEFAULT_BLOCK_HEIGHT;
        this.type = type;
    }

    public Block(float posX, float posY, float width, float height, BlockType type) {
        this.posX = posX;
        this.posY = posY;
        this.width = width;
        this.height = height;
        this.type = type;
    }

    public float getPosX() {
        return posX;
    }

    public float getPosY() {
        return posY;
    }

    public float getWidth() {
        return width;
    }

    public float getHeight() {
        return height;
    }

    public BlockType getType() {
        return type;
    }
}
