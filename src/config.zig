const Operator = @import("operator.zig").Operator;
const OperatorType = @import("operator.zig").OperatorType;

pub const Config = struct {
    pub const operators: []const Operator = &.{
        Operator.init(OperatorType.AND),
        Operator.init(OperatorType.OR),
        Operator.init(OperatorType.NOT),
        Operator.init(OperatorType.EQ),
        Operator.init(OperatorType.GTE), // gte before gt for tokenizer precedence
        Operator.init(OperatorType.GT),
        Operator.init(OperatorType.LTE), // lte before lt for tokenizer precedence
        Operator.init(OperatorType.LT),
    };
};
