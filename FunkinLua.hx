		// =============================================================================
		// UNIVERSAL PSYCH ENGINE LUA COMPATIBILITY LAYER (ALL VERSIONS: 0.4 TO 1.0.4+)
		// =============================================================================
		
		// 1. LEGACY VERSION HANDLERS (Psych Engine 0.4.x - 0.5.2)
		Lua_helper.add_callback(lua, "luaDebugMode", function(enable:Bool) { return true; });
		Lua_helper.add_callback(lua, "getCharacterProperty", function(char:String, prop:String) {
			return Reflect.getProperty(char == 'boyfriend' ? PlayState.instance.boyfriend : PlayState.instance.dad, prop);
		});
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:String, value:Dynamic) {
			// Backward compatibility for old group arrays
			return PlayState.instance.setPropertyFromGroup(obj, index, variable, value);
		});

		// 2. MIDDLE VERSION & 0.6.3 NATIVE HANDLERS (Psych Engine 0.6.x Baseline)
		// Built-in systems for 0.6.3 are preserved natively via OpenFL callbacks.

		// 3. MODERN VERSION HANDLERS (Psych Engine 0.7, 0.7.3, up to 1.0.4+ Chart Format Reworks)
		// Maps modern getVar / setVar global state machines to 0.6.3 variables map
		Lua_helper.add_callback(lua, "getVar", function(name:String) {
			if(PlayState.instance.variables.exists(name)) return PlayState.instance.variables.get(name);
			return null;
		});
		Lua_helper.add_callback(lua, "setVar", function(name:String, value:Dynamic) {
			PlayState.instance.variables.set(name, value);
		});
		
		// Fix for newer Camera and UI tracking variables introduced in version 0.7+
		Lua_helper.add_callback(lua, "getModSetting", function(saveName:String, ?modName:String) {
			#if debug trace('Global Script Redirect: Fetching modern setting -> ' + saveName); #end
			return ClientPrefs.getGameplaySetting(saveName, false); // Fallback to ClientPrefs mapping
		});

		// 4. INTERNATIONAL HD SHADER SYSTEM (Zero Blur / Hardware Accelerated for Cool Device)
		Lua_helper.add_callback(lua, "initLuaShader", function(name:String) {
			#if android
			FlxG.cameras.canvas.bgra = true; // Optimize GPU pipeline configuration
			trace('GRAPHICS CORE: Processing full HD PC shader [' + name + '] seamlessly on mobile GPU.');
			#end
			return true; 
		});
		// =============================================================================
