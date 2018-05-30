#pragma once

#include <vector>

#include "Gene.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Gene::Gene() :
	into(0),
	out(0),
	weight(0),
	enabled(true),
	innovation(0)
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Gene::Gene(const Gene &other) :
	into(other.into),
	out(other.out),
	weight(other.weight),
	enabled(other.enabled),
	innovation(other.innovation)
{
}