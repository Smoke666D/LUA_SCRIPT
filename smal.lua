function foo ( someInput )
  someOutput = someOutput + someInput
  foo( someInput );
  return someOutput;
end