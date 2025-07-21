--- @class Queue
--- @field items table<number, any>
--- @field head number
--- @field tail number
--- @field maxSize number|nil
--- @field comparator fun(a: any, b: any): boolean|nil
local Queue = {}

--- Creates a new Queue object
--- @param comparator fun(a: any, b: any): boolean|nil Optional comparator for ordered queue behavior
--- @param maxSize integer|nil Optional maximum queue size
--- @return Queue
function Queue:new(comparator, maxSize)
    local obj = {
        items = {},
        head = 1,
        tail = 0,
        maxSize = maxSize or nil,
        comparator = comparator or nil
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Queue:clear()
    self.items = {}
    self.head = 1
    self.tail = 0
end

function Queue:trim()
    if self:isEmpty() then
        self:clear()
    else
        error("Unable to trim queue; items still in queue.")
    end
end

function Queue:isEmpty()
    return self.head > self.tail
end

function Queue:contains(item)
    for i = self.head, self.tail do
        if self.items[i] == item then
            return true
        end
    end
    return false
end

--- Insert value maintaining order (if comparator exists)
--- @private
function Queue:_insertOrdered(value)
    local index = self.tail + 1
    for i = self.head, self.tail do
        if self.comparator(value, self.items[i]) then
            index = i
            break
        end
    end

    -- Shift elements forward to make room
    for j = self.tail, index, -1 do
        self.items[j + 1] = self.items[j]
    end

    self.items[index] = value
    self.tail = self.tail + 1
end

--- Add an item (value) to the back of the queue.
--- @param value any Value to be added to the queue
function Queue:enqueue(value)
    if self.maxSize and self:size() >= self.maxSize then
        error("Queue is full. Cannot enqueue.")
    end
    if self.comparator then
        self:_insertOrdered(value)
    else
        self.tail = self.tail + 1
        self.items[self.tail] = value
    end
end

function Queue:dequeue()
    if self:isEmpty() then
        error("Queue is empty. Cannot dequeue.")
    end

    local value = self.items[self.head]
    self.items[self.head] = nil
    self.head = self.head + 1
    return value
end

function Queue:size()
    return self.tail - self.head + 1
end

---Ensure that the queue has at least a specified capacity
---@param capacity integer
---@return integer
function Queue:ensureCapacity(capacity)
    if self.maxSize < capacity then
        self.maxSize = capacity
    end
    return self.maxSize
end

---Return the object at the beginning of the queue without removing it.
---@return any
function Queue:peek()
    if self:isEmpty() then
        return nil
    end

    return self.items[self.head]
end

---Copy the queue into a new array at index arrayIndex
---@param array table
---@param arrayIndex integer
function Queue:copyTo(array, arrayIndex)
    if array == nil then
        error("Please provide a valid array.")
    end

    if type(arrayIndex) ~= "number" or arrayIndex < 1 then
        error("The arrayIndex must be a positive integer.")
    end

    for i = 1, #self.items do
        array[arrayIndex + (i - 1)] = self.items[i]
    end
end

function Queue:drain()
    local result = {}
    while not self:isEmpty() do
        table.insert(result, self:dequeue())
    end
    return result
end

function Queue:enqueueUnique(value)
    if not self:contains(value) then
        self:enqueue(value)
    end
end

return Queue