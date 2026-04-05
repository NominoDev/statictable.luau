--!strict
--@NominoDev

export type StaticArrayType<T> = {
	insert: (value: T) -> (),
	remove: (key: number) -> T?,
	find: (value: T) -> number?,
	get: () -> {T},
	length: () -> number,
	clear: () -> ()
}
return {
	create = function<T>(size:number,t:{T}|nil)
		local private_table = table.create(size) :: {T}

		local StaticArray = {} :: StaticArrayType<T>
		StaticArray.insert = function(value:T)
			while #private_table >= size do
				table.remove(private_table,1)
			end
			table.insert(private_table,value)
		end
		StaticArray.remove = function(key:number)
			return table.remove(private_table,key)
		end
		StaticArray.find = function(value:T)
			return table.find(private_table,value)
		end
		StaticArray.get = function()
			return table.freeze(table.clone(private_table))
		end
		StaticArray.length = function() : number
			return #private_table
		end
		StaticArray.clear = function()
			table.clear(private_table)
		end
		
		if type(t)=="table" then
			for k in t do
				assert(type(k)=="number","StaticArray.create("..size..", t) -> t must be an array (must contain numbers as keys.)")
			end
			for _,v in ipairs(t) do
				StaticArray.insert(v)
			end
		end
		
		setmetatable(StaticArray,{
			__iter = function()
				return ipairs(private_table)
			end,
			__index = function(self:typeof(StaticArray),k:number|"insert"|"remove"|"find"|"get"|"length") : typeof(StaticArray)|T
				if type(k) == "number" then -- getting table directly here.
					return private_table[k]
				else
					return rawget(self,k) :: StaticArrayType<T> -- getting methods.
				end
			end,
			__newindex = function(self,k,v)
				if type(k) == "number" and k==math.floor(k) then
					if k<=size and k>0 then
						private_table[k] = v
						return
					else
						error("Attempt to write out of bound. StaticArray size range from 1 to "..size..". Got "..k)
					end
				else
					error("Attempt to write with a non number index. Only number indexes are accepted in arrays")
				end
			end
		})

		return StaticArray :: typeof(StaticArray)
	end,
}
