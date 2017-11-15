package com.senproj.luna.helpers;

public class CoordinateManager {

    public static float worldToPixel(int worldCoords) {
        return worldCoords * Settings.BLOCK_PIXELS;
    }

    public static float worldToPixel(float worldCoords) {
        return worldCoords * Settings.BLOCK_PIXELS;
    }

    public static int pixelToWorld(float pixelCoords) {
        return (int)pixelCoords / Settings.BLOCK_PIXELS;
    }
}
