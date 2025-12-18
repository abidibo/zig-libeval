var cnt: i16 = 0;

pub const OperandNode = struct {
    id: i16 = 0,
    symbol: []const u8 = "",
    depth: i16 = 0,

    pub fn init(symbol: []const u8, depth: i16) OperandNode {
        cnt += 1;
        return OperandNode{ .id = cnt, .symbol = symbol, .depth = depth };
    }
};

pub const UnaryOperatorNode = struct {
    id: i16 = 0,
    symbol: []const u8 = "",
    depth: i16 = 0,
    leftChild: *Node = undefined,

    pub fn init(symbol: []const u8, depth: i16, leftChild: *Node) UnaryOperatorNode {
        cnt += 1;
        return UnaryOperatorNode{ .id = cnt, .symbol = symbol, .depth = depth, .leftChild = leftChild };
    }
};

pub const BinaryOperatorNode = struct {
    id: i16 = 0,
    symbol: []const u8 = "",
    depth: i16 = 0,
    leftChild: *Node = undefined,
    rightChild: *Node = undefined,

    pub fn init(symbol: []const u8, depth: i16, leftChild: *Node, rightChild: *Node) BinaryOperatorNode {
        cnt += 1;
        return BinaryOperatorNode{ .id = cnt, .symbol = symbol, .depth = depth, .leftChild = leftChild, .rightChild = rightChild };
    }
};

pub const Node = union(enum) {
    operand: OperandNode,
    unaryOperator: UnaryOperatorNode,
    binaryOperator: BinaryOperatorNode,

    // The "Virtual Method"
    pub fn getId(self: Node) i16 {
        // Switch on self to find out which active field to access
        // 'inline else' auto-generates cases for all fields
        // that share the structure!
        switch (self) {
            inline else => |impl| return impl.id,
        }
    }

    pub fn getSymbol(self: Node) []const u8 {
        switch (self) {
            inline else => |impl| return impl.symbol,
        }
    }
};
