imon = {}
imon.oUF = {}
imon.debug = {}
imon.modules = {}

function imon:RegisterModule(name, f_create)
	imon.modules[name] = {
		create = f_create;
	}
end