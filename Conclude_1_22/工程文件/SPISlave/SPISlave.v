module SPISlave(
    input [1:0]      SPI_MODE,
    input            rst_i,         // rst
    output reg       EN_MOSI_ro,     // 指示是否可以使用Slave内MOSI的数据了，可以使用的时候会输出一个脉冲高电平
    input            EN_MOSI_i,     // 输入，指示此时MOSI的数据是否有效，有效时候应该是高电平
    output reg [7:0] MOSI_DT_ro,     // MOSI的数据输出，与上面的EN_MOSI_ro配套使用

    input            EN_MISO_i,     // 指示是否接受 MISO,1是可以，0是不可以
    input  [7:0]     MISO_DT_i,     // MISO 的 输入内容
    output           EN_MISO_o,     // 输出，指示此时MISO线的数据是否可用，可以使用的时候是高电平
    input      SPI_Clk_i,           // Clk

    output     MISO_o,              // 两根线
    input      MOSI_i,
    // CS: 1为选择，0为不选择。 这里我们先指让CS对MISO有影响；
    input      CS_i,
	output reg [2:0] MISO_cnt_r,    // MISO cnt, 用于指示此时的MISO到第几个数字了,改成了output方便调试
	output reg MISO_ro  //输出的reg,改成了output方便调试
    );
    // reg
    reg [2:0] MOSI_cnt_r;   // MOSI cnt，用于接收数据时候计数，从 000 到 111
    reg [7:0] MOSI_DT_r;    // 用于存储已经接收到的MOSI信号
    reg MOSI_EN_r;          // 用于确定确定此时的数据是否可以使用，并且这个是一个只会持续一个周期的小的脉冲,与上面的EN_MOSI_o配套使用

    //reg [2:0] MISO_cnt_r;   // MISO cnt, 用于指示此时的MISO到第几个数字了,改成了output方便调试
    reg [7:0] MISO_DT_r;    // MISO DT,用于存储MISO这一轮的八个数字
    reg MISO_EN_r;          // MISO 是否可以使用。可以使用的时候会是一个高电平持续，EN_MISO_o配套用
    //reg MISO_ro;            //输出的reg,改成了output方便调试
    // wire
    wire CPOL_w;
    wire CPHA_w;
    wire Clk_p_w; //这个依据不同mode进行定义
    wire MOSI_i_w; // 由CS控制
    //
    //
    // 1. CLK:
    // SPI_MODE有两位,第一位代表CPOL,第二位代表CPHA
    assign CPOL_w = SPI_MODE[1];
    assign CPHA_w = SPI_MODE[0];
    // 在设置完CPOL后可以对Clk_p_w定义
    assign Clk_p_w = CPOL_w ? ( CPHA_w? SPI_Clk_i : ~SPI_Clk_i ) : ( CPHA_w? ~SPI_Clk_i : SPI_Clk_i );
    // 现在就是：上升采样（指MOSI），下降输出（指MISO）
    //
    //
    //连线
    assign EN_MISO_o = MISO_EN_r;       //将输出和寄存器相连接
    assign MISO_o = (MISO_EN_r && CS_i) ?  MISO_ro  : 1'bz; // 如果EN 或者 CS 为0，输出高阻态
    assign MOSI_i_w = (EN_MOSI_i && CS_i )  ? MOSI_i : 1'bz;
    // 2.重置
    // 我们设置了重置模式,这个模式下主要要注意的是:
    // 对于外部信号：
    //  rst_i信号；  
    //  EN_MOSI_ro需要改为0； MOSI_DT_ro 改为全0; 因此MOSI_EN_r为0
    //  EN_MISO_ro需要改为0; MISO_EN_r 设置为0
    //  MISO_o 改为 1'bz
    // 对于内部信号：
    //  MOSI_cnt_r 需要设置为 3'b0 
    //  MOSI_DT_r   8'b0
    //  MISO_cnt_r 需要3'b0
    //  MISO_DT_r 需要8'b0
    // rst_i平时为0,为1时候会重置
    // 因为单独写会导致多驱动问题，所以在各个部分中加入
    //
    //MOSI的重置：EN_MOSI_ro, MOSI_DT_ro, MOSI_EN_r, MOSI_cnt_r, MOSI_DT_r, 
    //MISO的重置：MISO_ro, MISO_EN_r, MISO_o, MISO_cnt_r, MISO_DT_r

    // MOSI过程：
    // 1. 根据约定进行数据的接收
    // 此时需要的信号为 Clk_p_w;    EN_MOSI_i,MOSI_i, CS_i
    // 需要的内部信号为  CPOL_w 与 CPHA_w
    // 将会改变 MOSI_cnt_r MOSI_DT_r
    // 2. 完成8个数据接收之后，输出
    // 此时需要的信号为 MOSI_cnt_r MOSI_DT_r Clk_p_w
    // 改变的信号为 EN_MOSI_ro MOSI_DT_ro
    
    // 
    // （上升采样）
    always@( posedge rst_i or posedge Clk_p_w )
    begin
        if( rst_i ) // rst_i = 1,重置
        begin
            EN_MOSI_ro <= 1'b0;
            MOSI_DT_ro <= 8'b0;
            MOSI_EN_r <= 1'b0;
            MOSI_cnt_r <= 3'b000;
            MOSI_DT_r <= 8'b0;
        end
        else // 其他情况
        begin
            if( EN_MOSI_i == 1'b1 &&  CS_i == 1'b1 )
            // 如果EN,CS都为1
            begin
                MOSI_cnt_r <= MOSI_cnt_r + 1;
                MOSI_DT_r <= {MOSI_DT_r[6:0], MOSI_i_w };
                // 在这种情况下，输入是按照L先进的，例如:11110011,就是1,1,1,1,0,0,1,1
                // 否则就是{ MOSI_i, MOSI_DT_r[7:1] },变为1,1,0,0,1,1,1,1
                if( MOSI_cnt_r == 3'b000 )
                begin
                    // 满8个了
                    EN_MOSI_ro <= 1'b1;
                    MOSI_DT_ro <= MOSI_DT_r; 
                end
                else
                begin
                    // 对EN重置
                    EN_MOSI_ro = 1'b0;
                end
            end
        end
    end


    //MISO过程：
    //1. 收取8个数字，
    // 此时需要的信号为：EN_MISO_i, MISO_DT_i, SPI_Clk_i
    // 改变的是MISO_cnt_r, MISO_DT_r
    //2.  依次输出
    // 此时需要的信号为：MISO_cnt_r, MISO_DT_r
    // 改变的是：MISO_EN_r,MISO_ro
    //
    // //MISO的重置：MISO_ro, (MISO_o), MISO_EN_r, MISO_cnt_r, MISO_DT_r
    // 下降输出
    //
    // 但是对于不同的CPHA, 会有不同的情况
    // 我们设定一个额外的wire
    wire EN_MISO_CPHA = CPHA_w ? (1'b0) :EN_MISO_i;
    wire[2:0] MISO_cnt_w;
    assign MISO_cnt_w = MISO_cnt_r;
    // 因为如果只有一个cnt会出现无限循环的情况所以我们用两个
    reg[2:0] MISO_cnt_after_r;

    always @( negedge Clk_p_w )
    begin
        MISO_cnt_r <= MISO_cnt_after_r;
    end

    always @( posedge rst_i or posedge Clk_p_w or posedge EN_MISO_CPHA )
    begin
        //这样有了EN_MISO_CPHA,对于 CPHA_w=0 的情况,可以事先先将cnt=0的数据装入
        if( rst_i )
        begin
            MISO_ro <= 1'b0;
            MISO_EN_r <= 1'b0;
            // 这里不能写MISO_cnt_r否则会多驱动问题
            MISO_DT_r <= 8'b0;
            MISO_cnt_after_r <= 3'b0;
        end
        else
        begin
            //如果是第一个，为了让CPHA不同情况下都符合，我们让bit[0]直接赋给MISO_ro
            //首先先收取8个数字
            if( EN_MISO_CPHA == 1'b1 )
            begin
                // 这种情况下EN=1,是第一个数字而且是CPHA=1的情况
                if( MISO_cnt_w == 3'b0 )
                begin
                    MISO_DT_r <=  MISO_DT_i ;
                    MISO_ro <= MISO_DT_i[0];
                    MISO_cnt_after_r <= 3'b001 ;
                    MISO_EN_r <= 1'b1;
                end
                else
                begin
                    MISO_ro <= MISO_DT_r[MISO_cnt_r];
                    MISO_cnt_after_r <= MISO_cnt_r + 1;
                    MISO_EN_r <= 1'b1;
                end
            end
            else
            begin
                // CPHA = 0 的情况
                if( EN_MISO_i == 1'b1 )
                begin
                    if( MISO_cnt_w == 3'b0 )
                    begin
                        MISO_DT_r <=  MISO_DT_i ;
                        MISO_ro <= MISO_DT_i[0];
                        MISO_cnt_after_r <= 3'b001 ;
                        MISO_EN_r <= 1'b1;
                    end
                    else
                    begin
                        MISO_ro <= MISO_DT_r[MISO_cnt_r];
                        MISO_cnt_after_r <= MISO_cnt_r + 1;
                        MISO_EN_r <= 1'b1;
                    end
                end
                else
                begin
                    //EN=0,不做操作
                    ;
                end
            end
        end
    end
endmodule

