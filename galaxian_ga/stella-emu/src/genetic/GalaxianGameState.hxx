#ifndef GALAXIAN_GAME_STATE_HXX
#define GALAXIAN_GAME_STATE_HXX

#define MAX_ENEMIES 4

#include <vector>

class Console;
class Point;

class GalaxianGameState {
public:
	GalaxianGameState();
	~GalaxianGameState();

	int getPlayerScore();
	void killPlayer();
	bool isPlayerDead();
	bool isPlayerBulletActive();
	bool isGameRunning();
	int getPlayerPosition();
	std::vector<std::pair<int, int>> getEnemyPositions();

	void reset();
	void tick();
	void setConsole(Console *);
	std::vector<double> getInputs();
private:
	Console * myConsole;

	bool gameRunning;

	int enemyPosMemOffset;
	std::pair<int, int> enemyPosMem[3];
	std::vector<std::pair<int, int>> enemyPositions;
};

#endif