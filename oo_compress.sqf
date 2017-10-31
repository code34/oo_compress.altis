	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2017-2018 Nicolas BOITEUX

	CLASS OO_COMPRESS
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	#include "oop.h"

	CLASS("OO_COMPRESS")
		PRIVATE VARIABLE("string","stream");
		PRIVATE VARIABLE("array","map");
		PRIVATE VARIABLE("array","record");
		PRIVATE VARIABLE("string","data");

		PUBLIC FUNCTION("","constructor") {	
			MEMBER("stream", "1101010100101010101010101001010100101001010100101001010100100100010111001010101");
			private _array = [
				["A", 85,85], 
				["B", 23,23], 
				["C",6,6], 
				["D", 8,8], 
				["E",14,14], 
				["Z", 2,2], 
				["I", 20,2]
			];
			MEMBER("record", _array);

			MEMBER("map", []);
			MEMBER("data", "");

			player setVariable ["11", "A"];
			player setVariable ["1", "F"];
			player setVariable ["0", "B"];
			player setVariable ["01", "C"];
			player setVariable ["111", "D"];
			player setVariable ["1001", "G"];
		};

		PUBLIC FUNCTION("string","quantify") {
			private _result = [];
			private _index = 0;
			private _i = 0;
			private _test = toArray (_this);
			private _array = [];

			for "_i" from 0 to 256 step 1 do { _result set [_i, [0,0]]; };
			{
				_array = [(((_result select _x) select 0) + 1), toString[_x]];
				_result set [_x, _array];
			} forEach _test;

			for "_i" from 0 to 256 step 1 do { 
				if((_result select _i) isEqualTo [0,0]) then {
					_result set [_i, -1];
				};
			};
			_result = _result - [-1];
		};

		PUBLIC FUNCTION("scalar","generateIndex") {
			private _array = [];
			private _rank = [];
			private _end = [];
			private _square = 0;
			
			while { (_square ^ 2) < _this } do { _square = _square + 1;};
			for "_i" from 0 to _square step 1 do { _rank pushBack 0; _end pushBack 1;};

			private _count = (count _rank) - 1;
			private _index = _count;

			while { (count _array) -1 < _this  } do {
				if((_rank select _index) isEqualTo 0) then {
					_rank set [_index, 1];
				} else {					
					while { (_rank select _index) isEqualTo 1} do {
						_rank set [_index, 0];
						_index = _index - 1;
					};
					_rank set [_index, 1];
					_index = _count;
				};
				_array pushBack +_rank;
			};
			_array;
		};

		PUBLIC FUNCTION("array","getNextLeaf") {
			if(count _this < 1) exitWith {[]};
			private _array = _this;
			private _max = 1000;
			private _index = 0;	

			{
				if((_x select 2) < _max) then {
					_max = _x select 2;
					_index = _forEachIndex;
				};
			} forEach  _array;
			_array deleteAt _index;
		};


		PUBLIC FUNCTION("","createTree") {
			private _array = [[],[],0];
			private _element1 = MEMBER("getNextLeaf", MEMBER("record", nil));
			if!(_element1 isEqualTo []) then { 
				_array set [0, _element1]; 
				_array set[2, _element1 select 1];
			};

			private _element2 = MEMBER("getNextLeaf", MEMBER("record", nil));
			if!(_element2 isEqualTo []) then { 
				_array set [1, _element2]; 
				_array set [2, ((_array select 2) + (_element2 select 1))];
			};
			_array;
		};

		PUBLIC FUNCTION("","generateAllTree") {
			private _array = [];
			private _array2 = [];

			while {count MEMBER("record", nil) > 0} do {
				_array pushBack MEMBER("createTree", nil);
			};
			_array;
		};

		PUBLIC FUNCTION("scalar","getNextBit") {
			MEMBER("stream", nil) select _this;
		};

		PUBLIC FUNCTION("","decodeStream") {
			private _counter = 1;
			private _somme = 0;
			private _begin = 0;
			private _realbit = "";
			private _letterback = "";
			private _count = count MEMBER("stream", nil);
			private _stream = MEMBER("stream", nil);

			for "_i" from 0 to _count do {
				_element = _stream select [_begin, _counter];
				_letter = player getVariable [_element, []];
				if(_letter isEqualTo []) then { 
					_realbit = _realbit + _letterback; 
					_begin = _i + 1;
					_counter = 1;
				} else { 
					_letterback = _letter;
					_counter = _counter + 1;
				};
			};
			_realbit;
		};

		PUBLIC FUNCTION("string","compress") {
			MEMBER("data", _this);
			MEMBER("quantify", _this);
			MEMBER("createTree", nil);
		};

		PUBLIC FUNCTION("array","DecToBin") {
			private _binary = [];
			private _decimal = 0;
			private _bool = false;
			private _power = 0;

			{
				if (_x > 255) then {_decimal = 0;} else {_decimal = _x;};
				for "_i" from 7 to 0 step -1 do {
					_power = 2^(_i);
					_bool = (_power <= _decimal);
					_binary pushBack _bool;
					if (_bool) then {_decimal = _decimal - _power};
				};
			} count _this;
			_binary;
		};

		PUBLIC FUNCTION("array","BinToDec") {
			private _decimal = 0;
			private _decimals = [];
			private _bool = false;
			private _power = 0;

			while { count _this > 0} do {
				_decimal = 0;
				for "_i" from 7 to 0 step -1 do {
					_bool = _this deleteat 0;
					_power = 2^(_i);
					if(_bool) then {_decimal = _decimal + _power; };
				};
				if(_decimal isEqualTo 0) then { _decimal = 256;};
				_decimals pushBack _decimal;
			};
			_decimals;
		};

		PUBLIC FUNCTION("array","DecToHexa") {
			private _hexa = "0123456789ABCDEF";
			private _strings = "";

			{
				if(_x isEqualTo 256) then {_x = 0;};
				{
					_strings = _strings + (_hexa select [_x,1]);
				}foreach [floor (_x / 16), (_x mod 16)];
			} forEach _this;
			_strings;
		};

		PUBLIC FUNCTION("string","StrToHexa") {
			MEMBER("DecToHexa", toArray (_this));
		};

		PUBLIC FUNCTION("string","HexaToDec") {
			private _hexa = toArray "0123456789ABCDEF";
			private _array = toArray _this;
			private _decimals = [];
			private _decimal = 0;

			while { count _array > 0 } do {
				_decimal = (_hexa find (_array select 0)) * 16 + (_hexa find (_array select 1));
				if(_decimal isEqualTo 0) then {_decimal = 256;};
				_decimals pushBack _decimal;
				_array deleteRange [0,2];
			};
			_decimals;
		};

		PUBLIC FUNCTION("","deconstructor") { 

		};
	ENDCLASS;
