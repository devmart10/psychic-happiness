#include <iostream>

#include "Console.hxx"

#include "GalaxianGameState.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGameState::GalaxianGameState()
{
	reset();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGameState::~GalaxianGameState()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::reset() {
	enemyPosMemOffset = 2;
	enemyPositions.clear();
	gameRunning = false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::tick() {
	if (gameRunning) {
		for (int i = 0; i < 3; i++) {
			enemyPosMem[i].first = myConsole->retreiveByte(0xC0 + i);
			enemyPosMem[i].second = myConsole->retreiveByte(0xC5 + i);
		}

		if (enemyPosMem[enemyPosMemOffset].second == 0 || enemyPosMem[enemyPosMemOffset].second == 240) {
			if (--enemyPosMemOffset < 0) enemyPosMemOffset = 2;
		}
	}
	else {
		gameRunning = isGameRunning();
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGameState::isGameRunning() {
	return myConsole->retreiveByte(0xB9) < 3;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

vector<pair<int, int>> GalaxianGameState::getEnemyPositions() {
	enemyPositions.clear();

	for (int i = 0; i < 3; i++) {
		pair<int, int> pos = enemyPosMem[i];

		if (pos.second == 0) {
			enemyPositions.push_back(pair<int, int>(-127, -127));
		}
		else {
			enemyPositions.push_back(pos);
		}
	}

	return enemyPositions;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

pair<int, int> GalaxianGameState::getChargerPosition() {
	return enemyPosMem[enemyPosMemOffset];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::setConsole(Console *console) {
	myConsole = console;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int GalaxianGameState::getPlayerScore() {
	int tens = myConsole->retreivePartialByte(0xAE, 4, 0);
	int hundreds = myConsole->retreivePartialByte(0xAD, 4, 4);
	int thousands = myConsole->retreivePartialByte(0xAD, 4, 0);
	int ten_thousands = myConsole->retreivePartialByte(0xAC, 4, 4);
	int hun_thousands = myConsole->retreivePartialByte(0xAC, 4, 0);

	return tens * 10 + hundreds * 100 + thousands * 1000 +
		ten_thousands * 10000 + hun_thousands * 100000;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::killPlayer() {
	myConsole->placeByte(0xB2, 0x1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGameState::isPlayerDead() {
	return myConsole->retreiveByte(0xB2) != 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGameState::isPlayerBulletActive() {
	return myConsole->retreiveByte(0xB1) == 0x1F;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

vector<double> GalaxianGameState::getInputs() {
	vector<double> inputs;
	pair<int, int> chargerPos = getChargerPosition();
	int playerPos = getPlayerPosition();

	inputs.push_back(playerPos);
	inputs.push_back(isPlayerBulletActive());

	/* the six locations in memory containing enemy x and y locations */

	inputs.push_back(chargerPos.first);
	inputs.push_back(chargerPos.second);

	/* distance from player to enemy */
	/*double distance = sqrt(pow(chargerPos.first - playerPos, 2) + pow(chargerPos.second - 10, 2));
	inputs.push_back(distance);*/

	/* push the bias */
	inputs.push_back(rand() / (double)RAND_MAX);

	/* which enemies are still alive */
	/*
	for (int i = 0xA6; i <= 0xAB; i++) {
		for (int j = 0; j < 7; j++) {
			inputs.push_back(myConsole->retreivePartialByte(i, 1, j));
		}
	}
	inputs.push_back(myConsole->retreiveByte(0xB6));
	*/

	return inputs;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int GalaxianGameState::getPlayerPosition() {
	return myConsole->retreiveByte(0xE4);
}