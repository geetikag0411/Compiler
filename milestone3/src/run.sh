
echo Compiling Parser...
make
for i in {1..6}; do
    # echo "Running final_tests/test$i.py"
    ./parser --input=../final_tests/test$i.py --output=../output/x86$i.s
    gcc ../output/x86$i.s
    ./a.out > ../output/output$i
    python3 ../final_tests/test$i.py | sed 's/False/0/g; s/True/1/g' > ../output/python_output$i
    if diff  ../output/output$i ../output/python_output$i >/dev/null; then
        echo "final_tests/test$i PASSED"
    else
        echo "final_tests/test$i FAILED"
    fi
    
    echo "------------------------"
done

rm -f ./a.out


