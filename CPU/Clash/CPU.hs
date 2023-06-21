module Example.CPU where

import Clash.Prelude hiding (cycle)
import Clash.Signal (Signal, sample);
import Clash.Explicit.Testbench
import Data.Maybe

type Address = Unsigned 16
type Value = Signed 32
data Register = RA | RB | RC | RD deriving (Show, Generic, NFDataX)
data RegisterFile = RegisterFile (Vec 4 Value) deriving (Show, Generic, NFDataX)

data ROM = ROM (Vec 22 Value) deriving (Show, Generic, NFDataX)
readROM :: ROM -> Address -> Value
readROM (ROM rom) addr = rom !! addr

decodeRegister :: BitVector 4 -> Register
decodeRegister 0 = RA
decodeRegister 1 = RB
decodeRegister 2 = RC
decodeRegister 3 = RD

encodeRegister :: Register -> BitVector 4
encodeRegister RA = 0
encodeRegister RB = 1
encodeRegister RC = 2
encodeRegister RD = 3

readRegister :: RegisterFile -> Register -> Value
readRegister (RegisterFile regs) r = regs !! (encodeRegister r)

writeRegister :: RegisterFile -> Register -> Value -> RegisterFile
writeRegister (RegisterFile regs) r val = RegisterFile (replace (encodeRegister r) val regs)

data CPUStage = StageFetch | StageDecode | StageExecute | StageStore | Halted deriving (Show, Generic, NFDataX)

data CPUState = CPUState
    { registers :: RegisterFile
    , rom :: ROM
    , ir :: Instruction
    , litr :: Value
    , pc :: Address
    , inputX :: Value
    , inputY :: Value
    , out :: Value
    , flags :: BitVector 3
    , stage :: CPUStage
    } deriving (Show, Generic, NFDataX)

-- second instruction value
-- siv :: Register -> Bool -> Value -> RegisterFile -> Value
-- siv reg lit litr regs = if lit then litr else readRegister regs reg

toAddr :: Value -> Address
toAddr val = fromInteger $ toInteger $ slice d15 d0 val

cycle :: CPUState -> Value -> (CPUState, (Address, Maybe (Address, Value), Instruction))
-- -- cycle ((CPUState regs rom ram ir litr pc flags stage), b) = case stage of
cycle (CPUState regs rom ir litr pc inputX inputY aluOut flags stage) ramOut = case stage of
    Halted -> ((CPUState regs rom ir litr pc inputX inputY aluOut flags Halted), (0, Nothing, ir))

    StageFetch -> ((CPUState regs rom ir' litr' pc inputX inputY aluOut flags StageDecode), (0, Nothing, ir)) where
        ir' = decodeInstruction $ readROM rom pc
        litr' = readROM rom (pc + 1)

    StageDecode -> ((CPUState regs rom ir litr pc inputX' inputY' aluOut flags StageExecute), (0, Nothing, ir)) where
        inputX' = case ir of
            BinOp op r1 r2 lit -> readRegister regs r1
            UnOp op r lit -> 0
            _ -> 0
        inputY' = case ir of
            BinOp op r1 r2 lit -> if lit then litr else readRegister regs r2
            UnOp op r lit ->if lit then litr else readRegister regs r
            _ -> 0

    StageExecute -> case ir of
        Stop -> ((CPUState regs rom ir litr pc inputX inputY aluOut flags Halted), (0, Nothing, ir))

        _ -> ((CPUState regs rom ir litr pc inputX inputY aluOut' flags' StageStore), (rd', Nothing, ir)) where
            aluOut' = case ir of
                BinOp Mov r1 r2 lit -> inputY
                BinOp Add r1 r2 lit -> inputX + inputY
                BinOp Sub r1 r2 lit -> inputX - inputY
                BinOp Mul r1 r2 lit -> inputX * inputY
                _ -> inputY
            flags' = case ir of
                BinOp Cmp r1 r2 lit -> result
                    where
                        result = case inputX `compare` inputY of
                            LT -> 0b001
                            EQ -> 0b010
                            GT -> 0b100
                _ -> flags
            rd' = case ir of
                    BinOp Load r1 r2 lit -> toAddr inputY
                    _ -> 0

    StageStore -> ((CPUState regs' rom ir litr pc' inputX inputY aluOut flags StageFetch), (0, wr', ir)) where
        wr' = case ir of
            BinOp Store r1 r2 lit -> Just (toAddr inputX, inputY)
            _ -> Nothing

        regs' = case ir of
            BinOp Load r1 r2 lit -> writeRegister regs r1 ramOut
            BinOp _ r1 _ _ -> writeRegister regs r1 aluOut
            _ -> regs

        pc' = case ir of
            UnOp Jmp r lit -> toAddr inputY
            UnOp JE r lit | flags == 0b010 -> toAddr inputY
            UnOp JNE r lit | flags /= 0b010 -> toAddr inputY
            UnOp JG r lit | flags == 0b100 -> toAddr inputY
            UnOp JS r lit | flags == 0b001 -> toAddr inputY
            BinOp op r1 r2 True -> (pc + 2)
            UnOp op r True -> (pc + 2)
            Stop -> pc
            _ -> pc + 1


-- cycle :: CPUState -> CPUState
-- cycle (CPUState regs rom ram ir litr pc flags stage) = case stage of
--     Halted -> CPUState regs rom ram ir litr pc flags Halted

--     StageFetch -> (CPUState regs rom ram ir' litr' pc flags StageExecute) where
--         ir' = decodeInstruction $ readROM rom pc
--         litr' = readROM rom (pc + 1)
--     StageExecute -> case ir of
--         Stop -> CPUState regs rom ram ir litr pc flags Halted
--         _ -> CPUState regs' rom ram' ir litr pc flags' StageStore where
--                 regs' = case ir of
--                         BinOp Mov r1 r2 lit -> writeRegister regs r1 (siv r2 lit litr regs)
--                         BinOp Add r1 r2 lit -> writeRegister regs r1 ((readRegister regs r1) + (siv r2 lit litr regs))
--                         BinOp Sub r1 r2 lit -> writeRegister regs r1 ((readRegister regs r1) - (siv r2 lit litr regs))
--                         BinOp Mul r1 r2 lit -> writeRegister regs r1 ((readRegister regs r1) * (siv r2 lit litr regs))
--                         -- BinOp Div r1 r2 lit -> writeRegister regs r1 ((pack $ readRegister regs r1) `div` (pack $ siv r2 lit litr regs))
--                         BinOp Load r1 r2 lit -> writeRegister regs r1 (readRAM ram (toAddr $ siv r2 lit litr regs))
--                         _ -> regs
--                 flags' = case ir of
--                         BinOp Cmp r1 r2 lit -> result
--                                 where
--                                         reg1 = readRegister regs r1
--                                         reg2 = siv r2 lit litr regs
--                                         result = case reg1 `compare` reg2 of
--                                                 LT -> 0b001
--                                                 EQ -> 0b010
--                                                 GT -> 0b100
--                         _ -> flags
--                 ram' = case ir of
--                         BinOp Store r1 r2 lit -> writeRAM ram (toAddr $ readRegister regs r1) (siv r2 lit litr regs)
--                         _ -> ram
--     StageStore -> CPUState regs rom ram ir litr pc' flags StageFetch where
--         pc' = case ir of
--                 UnOp Jmp r lit -> (toAddr $ siv r lit litr regs)
--                 UnOp JE r lit -> if flags == 0b010 then (toAddr $ siv r lit litr regs) else (pc + (if lit then 2 else 1))
--                 UnOp JNE r lit -> if flags /= 0b010 then (toAddr $ siv r lit litr regs) else (pc + (if lit then 2 else 1))
--                 UnOp JG r lit -> if flags == 0b100 then (toAddr $ siv r lit litr regs) else (pc + (if lit then 2 else 1))
--                 UnOp JS r lit -> if flags == 0b001 then (toAddr $ siv r lit litr regs) else (pc + (if lit then 2 else 1))
--                 BinOp op r1 r2 True -> (pc + 2)
--                 Stop -> pc
--                 _ -> pc + 1

data UnOpType = Jmp | JE | JNE | JG | JS deriving (Show, Generic, NFDataX)
data BinOpType = Mov | Load | Store | Add | Sub | Mul | Div | Cmp deriving (Show, Generic, NFDataX)

data Instruction =
    NOP | Stop |
    UnOp UnOpType Register Bool |
    BinOp BinOpType Register Register Bool deriving (Show, Generic, NFDataX)

decodeInstruction :: Value -> Instruction
decodeInstruction instr = case op of
    0 -> NOP
    0x2 -> BinOp Mov r1 r2 lit
    0x3 -> BinOp Store r1 r2 lit
    0x4 -> BinOp Load r1 r2 lit
    0x10 -> BinOp Add r1 r2 lit
    0x11 -> BinOp Sub r1 r2 lit
    0x12 -> BinOp Mul r1 r2 lit
    0x13 -> BinOp Div r1 r2 lit
    0x18 -> BinOp Cmp r1 r2 lit
    0x40 -> UnOp Jmp r2 lit
    0x41 -> UnOp JE r2 lit
    0x42 -> UnOp JNE r2 lit
    0x43 -> UnOp JG r2 lit
    0x44 -> UnOp JS r2 lit
    0xff -> Stop
    where
        op = slice d23 d16 instr
        r1 = decodeRegister $ slice d15 d12 instr
        r2 = decodeRegister $ slice d11 d8 instr
        lit = if slice d2 d1 instr == 0b0 then False else True

encodeInstruction :: Instruction -> BitVector 8
encodeInstruction instr = case instr of
    NOP -> 0
    Stop -> 0xff
    UnOp op r lit -> case op of
        Jmp -> 0x40
        JE -> 0x41
        JNE -> 0x42
        JG -> 0x43
        JS -> 0x44

    BinOp op _ _ _ -> case op of
        Mov -> 0x2
        Store -> 0x3
        Load -> 0x4
        Add -> 0x10
        Sub -> 0x11
        Mul -> 0x12
        Div -> 0x13
        Cmp -> 0x18

isHalted :: Instruction -> Bool
isHalted Stop = True
isHalted _ = False

cpuHardware :: (HiddenClockResetEnable dom) => CPUState -> Signal dom (BitVector 8)
cpuHardware initState = op where
    (rdAddr, ramWr, inst) = mealyB cycle initState ramOut
    op = fmap encodeInstruction inst
    ramOut = blockRam (replicate d1024 (0 :: Value)) rdAddr ramWr

program :: CPUState
program = CPUState registers rom ir litr pc inputX inputY out flags StageFetch where
    registers = RegisterFile (replicate d4 0)
    rom = ROM (
            0x00020002 :>
            0x00000000 :>
            0x00021002 :>
            0x00000001 :>
            0x00023002 :>
            0x0000000a :>
            0x00030002 :>
            0x00000000 :>
            0x00121002 :>
            0x00000002 :>
            0x00040000 :>
            0x00100002 :>
            0x00000001 :>
            0x00113002 :>
            0x00000001 :>
            0x00030000 :>
            0x00180002 :>
            0x0000000a :>
            0x00440002 :>
            0x00000008 :>
            0x00ff0000 :>
            0x00000000 :>
            Nil
        )
    ir = NOP --decodeInstruction $ readROM rom pc
    litr = 0 --readROM rom (pc + 1)
    pc = 0
    inputX = 0
    inputY = 0
    out = 0
    flags = 0b000
    stage = StageFetch

topEntity :: Clock System -> Reset System -> Enable System -> Signal System (BitVector 8)
topEntity = exposeClockResetEnable $ cpuHardware program

-- main :: IO()
-- main = do
    -- let init = cpuHardware program

    -- putStrLn $ show $ init

testBench :: Signal System (BitVector 8)
testBench = op where
    op = topEntity clk rst en
    en = enableGen
    rst = systemResetGen
    clk = tbSystemClockGen (pure True)
