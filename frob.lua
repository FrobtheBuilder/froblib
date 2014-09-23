frob = {}

-- convenience function to quickly compose an object
function frob.object(...)
	return frob.extend({}, ...)
end

function frob.advObj(ext, app)
	local obj = {}
	frob.extend(obj, unpack(ext))
	frob.append(obj, app)
	return obj
end

-- takes any number of tables and shoves their contents into t
function frob.extend(t, ...)
	for i,v in ipairs{...} do
		for k,v2 in pairs(v) do
			if type(k) ~= "table" then
				t[k] = v2
			else
				t[k]= frob.extend({}, v2)
			end
		end
	end
	return t;
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
	return t --so you can chain it with object()
end

-- add this to a table, redefine construct() and call new() with the arguments you made construct take
-- that will return a copy of the table with construct run on it
frob.class = {}
function frob.class:construct(...) end --stub. to be defined in implementation
function frob.class:new(...)
	copy = frob.extend({}, self)
	copy.template = self
	copy:construct(...)
	return copy
end


frob.evt = {events = {}}
frob.eventEmitter = frob.evt

-- add an event, and a function to run when it's fired
function frob.evt:on(event, listener)
	if not self.events[event] then
		self.events[event] = {}
	end

	table.insert(self.events[event], listener)
end

-- remove a listener from a specified event
function frob.evt:off(event, listener)
	for k,v in pairs(self.events[event]) do
		if v == listener then
			k = nil
		end
	end
end

-- fire an event with some arguments to pass to the target function
function frob.evt:fire(event, ...)
	for k,v in pairs(self.events[event]) do
		if type(v) == "function" then
			v(...)
		end
	end
end

frob.evt.addListener = frob.evt.on
frob.evt.removeListener = frob.evt.off

return frob