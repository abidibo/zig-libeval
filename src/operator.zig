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
    regex_str: []const u8 = "",

    pub fn init(operatorType: OperatorType) Operator {
        var precedence: u8 = 1;
        var unary: bool = false;
        var symbol: []const u8 = "";
        var regex_str: []const u8 = "";

        switch (operatorType) {
            OperatorType.AND => {
                symbol = "&&";
                regex_str = "^&&";
            },
            OperatorType.OR => {
                symbol = "||";
                regex_str = "^\\|\\|";
            },
            OperatorType.NOT => {
                symbol = "!";
                regex_str = "^!";
                unary = true;
                precedence = 3;
            },
            OperatorType.EQ => {
                symbol = "==";
                regex_str = "^==";
                precedence = 2;
            },
            OperatorType.GT => {
                symbol = ">";
                regex_str = "^>";
                precedence = 2;
            },
            OperatorType.GTE => {
                symbol = ">=";
                regex_str = "^>=";
                precedence = 2;
            },
            OperatorType.LT => {
                symbol = "<";
                regex_str = "^<";
                precedence = 2;
                precedence = 2;
            },
            OperatorType.LTE => {
                symbol = "<=";
                regex_str = "^<=";
            },
        }

        return Operator{
            .operator_type = operatorType,
            .precedence = precedence,
            .symbol = symbol,
            .regex_str = regex_str,
        };
    }
};
