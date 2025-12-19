pub const OperatorType = enum {
    AND,
    OR,
    NOT,
    EQ,
    GT,
    GTE,
    LT,
    LTE,
};

pub const Operator = struct {
    operator_type: OperatorType,
    precedence: u8,
    symbol: []const u8 = "",

    pub fn init(operatorType: OperatorType) Operator {
        var precedence: u8 = 1;
        var unary: bool = false;
        var symbol: []const u8 = "";

        switch (operatorType) {
            OperatorType.AND => {
                symbol = "&&";
            },
            OperatorType.OR => {
                symbol = "||";
            },
            OperatorType.NOT => {
                symbol = "!";
                unary = true;
                precedence = 3;
            },
            OperatorType.EQ => {
                symbol = "==";
                precedence = 2;
            },
            OperatorType.GT => {
                symbol = ">";
                precedence = 2;
            },
            OperatorType.GTE => {
                symbol = ">=";
                precedence = 2;
            },
            OperatorType.LT => {
                symbol = "<";
                precedence = 2;
            },
            OperatorType.LTE => {
                symbol = "<=";
            },
        }

        return Operator{
            .operator_type = operatorType,
            .precedence = precedence,
            .symbol = symbol,
        };
    }
};
