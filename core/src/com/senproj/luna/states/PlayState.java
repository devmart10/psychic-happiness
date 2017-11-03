package com.senproj.luna.states;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.maps.MapObject;
import com.badlogic.gdx.maps.objects.PolygonMapObject;
import com.badlogic.gdx.maps.objects.RectangleMapObject;
import com.badlogic.gdx.math.Polygon;
import com.badlogic.gdx.math.Rectangle;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.*;
import com.senproj.luna.helpers.Settings;
import com.senproj.luna.hud.Hud;
import com.senproj.luna.map.GameMap;
import com.senproj.luna.sprites.Player;

import static com.senproj.luna.LunaGame.batch;

public class PlayState extends GameState {
    private static final Vector2 gravity = new Vector2(0, 0);
    private GameMap gamemap;
    private Player player;
    private Hud hud;

    private World world;
    private Box2DDebugRenderer b2dr;

    public PlayState(GameStateManager gsm) {
        super(gsm);

        // creating the world
        world = new World(gravity, true);
        b2dr = new Box2DDebugRenderer();

        gamemap = new GameMap(camera);
        player = new Player(gamemap, world);
        hud = new Hud(player);
        camera.setToOrtho(false, Settings.SCREEN_WIDTH / 2.0f, Settings.SCREEN_HEIGHT / 2.0f);

        BodyDef bodyDef = new BodyDef();
        PolygonShape shape = new PolygonShape();
        FixtureDef fixtureDef = new FixtureDef();
        Body body;

        // buildings layer
        for(MapObject object : gamemap.getMap().getLayers().get("BuildingCollisions").getObjects().getByType(RectangleMapObject.class)) {
            Rectangle rect = ((RectangleMapObject) object).getRectangle();

            bodyDef.type = BodyDef.BodyType.StaticBody;
            bodyDef.position.set(rect.getX() + rect.getWidth() / 2, rect.getY() + rect.getHeight() / 2);

            body = world.createBody(bodyDef);

            shape.setAsBox(rect.getWidth() / 2, rect.getHeight() / 2);
            fixtureDef.shape = shape;
            body.createFixture(fixtureDef);
        }

        // terrain layer
        for(MapObject object : gamemap.getMap().getLayers().get("TerrainCollisions").getObjects().getByType(PolygonMapObject.class)) {
            Polygon polygon = ((PolygonMapObject) object).getPolygon();
            float vertices[] = polygon
                    .getTransformedVertices();
            for (int x = 0; x < vertices.length; x++) {
                vertices[x] /= 1;
            }
            ChainShape shape2 = new ChainShape();
            shape2.createChain(vertices);
            fixtureDef.shape = shape2;

            bodyDef.position.set(0, 0);
            bodyDef.type = BodyDef.BodyType.StaticBody;

            body = world.createBody(bodyDef);

            body.createFixture(fixtureDef);
        }

    }

    @Override
    public void update(float dt) {
        world.step(1/60f, 6, 2);

        player.update(dt);
        hud.update(dt);
        camera.position.set(player.getPosition(), camera.position.z);
        camera.update();
        handleInput();
    }

    @Override
    public void render() {
        gamemap.render();

        // toggle on/off for world body debug lines
        b2dr.render(world, camera.combined);

        batch.setProjectionMatrix(camera.combined);
        player.draw();
        hud.stage.draw();
    }

    @Override
    public void handleInput() {
        if (Gdx.input.isKeyPressed(Input.Keys.ESCAPE)) {
            Gdx.app.exit();
        }
    }

    @Override
    public void dispose() {
        gamemap.dispose();
        player.dispose();
    }
}
