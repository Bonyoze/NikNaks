-- Copyright © 2022-2072, Nak, https://steamcommunity.com/id/Nak2/
-- All Rights Reserved. Not allowed to be reuploaded.

-- NodeGrapth Alias and logic
do
	local hasFile = file.Exists("maps/graphs/" .. game.GetMap() .. ".ain", "GAME")
	local NGarph = NodeGraph.LoadAin()

	hook.Add("NN_PRE_INIT_AIN", "Load_NodeGraph", function() -- AIN will call this hook, when it is safe to load.
		NGarph = NodeGraph.LoadAin()
		if NGarph then
			hook.Run("NodeGraph_Init")
		end
	end)

	---Returns the AIN version. Should be 37.
	---@return number
	function NodeGraph.GetVersion( )
		return NGarph and NGarph:GetVersion( )
	end

	---Returns the AIN map-version.
	---@return number
	function NodeGraph.GetMapVersion( )
		return NGarph and NGarph:GetMapVersion( )
	end

	---Returns the given ain_node at said ID. 
	---@param id number
	---@return ain_node
	function NodeGraph.GetNode( id )
		return NGarph and NGarph:GetNode( id )
	end

	---Returns the nearest node
	---@param position Vector
	---@param NODE_TYPE? number
	---@param Zone? number
	---@return ain_node
	function NodeGraph.FindNode( position, NODE_TYPE, Zone, HULL )
		return NGarph and NGarph:FindNode( position, NODE_TYPE, Zone, HULL )
	end

	---Returns the nearest node with a connection matching the hull.
	---@param position Vector
	---@param NODE_TYPE? number
	---@param HULL number
	---@param Zone? number
	---@return ain_node
	function NodeGraph.FindNodeWithHull( position, NODE_TYPE, Zone, HULL )
		return NGarph and NGarph:FindNodeWithHull( position, NODE_TYPE, Zone, HULL )
	end

	---Returns the nearest node with said HintType.
	---@param position Vector
	---@param NODE_TYPE? number
	---@param HintType number
	---@param HintGroup? number
	---@param Zone? number
	---@return ain_node
	function NodeGraph.FindHintNode( position, NODE_TYPE, HintType, HintGroup, Zone, HULL)
		return NGarph and NGarph:FindHintNode( position, NODE_TYPE, HintType, HintGroup, Zone, HULL)
	end

	---A* pathfinding using the NodeGraph.
	---@param start_pos Vector|Entity
	---@param end_pos Vector|Entity
	---@param NODE_TYPE? number
	---@param HULL_SIZE? number
	---@param options? table
	---@param generator? function		-- A funtion that allows you to calculate your own cost: func( node, fromNode, CAP_MOVE, elevator, length )
	---@return LPathFollower|boolean
	function NodeGraph.PathFind( start_pos, end_pos, NODE_TYPE, options, HULL_SIZE, generator )
		return NGarph and NGarph:PathFind( start_pos, end_pos, NODE_TYPE, options, HULL_SIZE, generator )
	end

	---A cheap lookup function. Checks to see if we can reach the position using nearby nodes.
	---Note that this use zones and might have false positives on maps with a broken NodeGraph.
	---@param start_pos Vector
	---@param end_pos Vector
	---@param NODE_TYPE? number
	---@param HULL_SIZE? number
	---@param max_dis? number -- Distance to nearest node
	---@return boolean
	function NodeGraph.CanMaybeReach( start_pos, end_pos, NODE_TYPE, HULL_SIZE, max_dis ) 
		return NGarph and NGarph:CanMaybeReach( start_pos, end_pos, NODE_TYPE, HULL_SIZE, max_dis ) 
	end

	---A* pathfinding using the NodeGraph. Returns the result in the callback. Calculates 20 paths pr tick.
	---@param start_pos Vector|Entity
	---@param end_pos Vector|Entity
	---@param callback function 		-- Returns the result. LPathFollower or false
	---@param NODE_TYPE? number
	---@param HULL_SIZE? number
	---@param BitCapability? number
	---@param JumpMultiplier? number 	-- How much jumping / flying cost over walking
	---@param generator? function		-- A funtion that allows you to calculate your own cost: func( node, fromNode, CAP_MOVE, elevator, length )
	---@param MaxDistance? number		-- Searching with in a range, can lower the cost over longer / difficult terrain.
	---@param UseZone? boolean			-- Setting this to false will make it slower, but work on broken NodeGraphs.
	function NodeGraph.PathFindASync( start_pos, end_pos, callback, NODE_TYPE, HULL_SIZE, BitCapability, JumpMultiplier, generator, MaxDistance, UseZone )
		return NGarph and NGarph:PathFindASync( start_pos, end_pos, callback, NODE_TYPE, HULL_SIZE, BitCapability, JumpMultiplier, generator, MaxDistance, UseZone )
	end

	---Returns true if the nodegraph for the current map has loaded
	---@return boolean
	function NodeGraph.HasLoaded()
		return NGarph and true or false
	end

	---Tries to reload the NodeGraph
	function NodeGraph.Reload()
		NGarph = NodeGraph.LoadAin()
	end
end

-- NikNaks Alis and logic
do
	local NNN_Mesh
	hook.Add("InitPostEntity", "NN_Load_NNN", function()
		if file.Exists("nnn/" .. game.GetMap() .. ".dat", "GAME") then
			NNN_Mesh = NNN.Load()
		elseif file.Exists("maps/" .. game.GetMap() .. ".nav", "GAME") then -- Generate NNN
			NNN_Mesh = NNN.GenerateFromNav()
			if not NNN_Mesh then return end
			NNN_Mesh:Save()
			NikNaks.Msg("Generated NNN!")
		end
	end)

	---Returns true if the NNN has loaded
	---@return boolean
	function NNN.HasLoaded()
		return NNN_Mesh and true or false
	end

	---Tries to load or generate the NNN
	function NNN.Reload()
		if file.Exists("nnn/" .. game.GetMap() .. ".dat", "GAME") then
			NNN_Mesh = NNN.Load()
		elseif file.Exists("maps/" .. game.GetMap() .. ".nav", "GAME") then -- Generate NNN
			NNN_Mesh = NNN.GenerateFromNav()
			if not NNN_Mesh then return end
			NNN_Mesh:Save()
			NikNaks.Msg("Generated NNN!")
		end
	end

	---@param start_position Vector
	---@param end_position Vector
	---@param width? number
	---@param height? number
	---@param options? table				A table of options: 
	---@param generator? function 			A function to modify the cost: func( FromArea, ToArea, connection, BitCapability, CurrentCost )
	function NNN.PathFind( start_position, end_position, width, height, options, generator )
		if not NNN_Mesh then return end
		return NNN_Mesh:PathFind( start_position, end_position, width, height, options, generator )
	end

	if false and CLIENT then
		local t = ents.FindByClass("prop_physics")
		local A = t[1]
		local B = t[2]
		local C = t[3]

		local cost = 0
		local options = {}
		options.StepHeight = 30
		options.ClimbMultiplier = 0.8
		hook.Add("PostDrawOpaqueRenderables", "T", function(a, b)
			if NNN_Mesh and NNN then
				NNN_Mesh:DebugRender()
			else 
				return
			end
			if not A or not B then return end
			local v = A:OBBMaxs() - A:OBBMins()
			local s = SysTime()
			local result = NNN_Mesh:PathFind( A:GetPos(), B:GetPos(), 16 or math.max(v.x, v.y), v.z, options, nil)
			local result2 = NodeGraph.PathFind( A:GetPos(), C:GetPos(), NODE_TYPE_GROUND, nil, HULL_HUMAN )

			cost = SysTime() - s
			if result == false then
				local ang = EyeAngles()
				ang:RotateAroundAxis( ang:Up(), -90 )
				ang:RotateAroundAxis( ang:Forward(), 90 )
				cam.Start3D2D( A:GetPos() + Vector(0,0, 30), ang, 0.1 )
					draw.DrawText( string.format("Cost: %fms", cost), "TargetID", 0,0, color_white, TEXT_ALIGN_CENTER )
				cam.End3D2D()
				return
			end
			if result == true then
				render.DrawLine( A:GetPos(), B:GetPos(), color_white)
			else
				result:DebugRender()
			end
			if result2 and result2 ~= true and result2 ~= false then
				result2:DebugRender()
			end

			
			local ang = EyeAngles()
			ang:RotateAroundAxis( ang:Up(), -90 )
			ang:RotateAroundAxis( ang:Forward(), 90 )
			cam.Start3D2D( A:GetPos() + Vector(0,0, 30), ang, 0.1 )
				draw.DrawText( string.format("Cost: %fms", cost), "TargetID", 0,0, color_white, TEXT_ALIGN_CENTER )
			cam.End3D2D()
		end)
	end
end