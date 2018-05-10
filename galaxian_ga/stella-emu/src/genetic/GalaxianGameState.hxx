#ifndef GALAXIAN_GAME_STATE_HXX
#define GALAXIAN_GAME_STATE_HXX

#define MAX_ENEMIES 4

class Console;
class Point;

#include <vector>

class GalaxianGameState {
public:
	GalaxianGameState();
	~GalaxianGameState();

	int getPlayerScore();
	bool isPlayerDead();
	int getPlayerPosition();
	std::vector<std::pair<int, int>> getEnemyPositions();

	void reset();
	void tick();
	void setConsole(Console *);
private:
	Console * myConsole;

	bool gameRunning;

	int enemyPosMemOffset;
	std::pair<int, int> enemyPosMem[3];
	std::vector<std::pair<int, int>> enemyPositions;
};

#endif