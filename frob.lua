local frob = {}

-- convenience function to quickly compose an object
function frob.object(...)
	return frob.extend({}, ...)
end

-- compose a table with some extensions and appendixes
function frob.advObj(ext, app)
	local obj = {}
	frob.extend(obj, unpack(ext))
	frob.append(obj, app)
	return obj
end

-- takes any number of tables and shoves their contents into t
function frob.extend(t, ...)
	for i,v in ipairs{...} do
		for k,v2 in next, v, nil do
			if type(v2) ~= "table" then
				t[k] = v2
			else
				t[k] = frob.extend({}, v2)
			end
		end
	end
	return t -- and return the table
end

-- like extend but doesn't dump contents into object directly
-- takes a table like {e = frob.evt} and gives the table given an e field populated with contents
-- if the extension requires :self access to the main object (like frob.class) it will clearly break
-- BUT you can get it back by referencing the "parent" property that's added
function frob.append(t, tbs)
	for k, v in pairs(tbs) do
		t[k] = frob.object(v)
		t[k].parent = t
	end
	return t --so you can chain it with object() if you really want to
end

-- add this to a table, redefine construct() and call new() with the arguments you made construct take
-- that will return a copy of the table with construct run on it
-- extend, not append pls.
frob.class = {}
function frob.class:construct(...) end --stub. to be defined in implementation
function frob.class:new(...)
	copy = frob.extend({}, self)
	copy.template = self
	copy:construct(...)
	copy.construct = nil
	copy.new = nil
	return copy
end

-- event emitter/handler. fine for either extending or appending
frob.evt = {private = {events = {}}}
frob.eventEmitter = frob.evt

-- add an event, and a function to run when it's fired
function frob.evt:on(event, listener)
	if not self.private.events[event] then
		self.private.events[event] = {}
	end

	table.insert(self.private.events[event], listener)
end

-- remove a listener from a specified event
function frob.evt:off(event, listener)
	for k,v in pairs(self.private.events[event]) do
		if v == listener then
			k = nil
		end
	end
end

function frob.evt:allOff(event)
	self.private.events[event] = nil
end

-- fire an event with some arguments to pass to the target function
function frob.evt:fire(event, ...)
	if self.private.events and self.private.events[event] then
		for i,v in ipairs(self.private.events[event]) do
			if type(v) == "function" then
				v(...)
			end
		end
	end
end

frob.evt.addListener = frob.evt.on
frob.evt.removeListener = frob.evt.off
frob.evt.removeAllListeners = frob.evt.allOff

return frob