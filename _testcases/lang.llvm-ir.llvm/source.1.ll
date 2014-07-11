; ModuleID = 'Bunchou'

@0 = private unnamed_addr constant [8 x i8] c"ABCDEFG\00"

define i8 @main() {
entrypoint:
  %0 = call i32 @puts(i8* getelementptr inbounds ([8 x i8]* @0, i32 0, i32 0))
  ret i8 72
}

declare i32 @puts(i8*)
