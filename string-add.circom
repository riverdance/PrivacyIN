//string-add.circom

pragma circom 2.0.0;

/*This circuit template checks that c is the addition of a and b.*/  

template binaryCheck () {
   // Declaration of signals.
   signal input in;
   signal output out;

   // Statements.
   in * (in-1) === 0;
   out <== in;
}

// this is from circomlib bitify.circom
template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    lc1 === in;
}

// OR logic gate to 2 inputs
template Or2(){
   //Declaration of signals and components.
   signal input in1;
   signal input in2;
   signal output out;
   signal output carry;
   component add = Addition2();
   component binCheck[2];

   //Statements.
   binCheck[0] = binaryCheck();
   binCheck[0].in <== in1;
   binCheck[1] = binaryCheck();
   binCheck[1].in <== in2;
   out <== binCheck[0].out + binCheck[1].out;
   carry <== binCheck[0].out * binCheck[1].out;
}

// use OR logic gate to add two 256-bit strings
template strAdd(N){
   //Declaration of signals and components.
   signal input a;
   signal input b;
   signal output out[N];
   component or[N];
   component num2Bits[2];

   num2Bits[0] = Num2Bits(N);
   num2Bits[0].in <== a;
   var in1[N] = num2Bits[0].out;

   num2Bits[1] = Num2Bits(N);
   num2Bits[1].in <== b;
   var in2[N] = num2Bits[1].out;

   //Statements.
    for(var i = 0; i < N; i++){
        or[i] = Or2();
        or[i].in1 <== in1[i];
        or[i].in2 <== in2[i];

        if (i==0){
            out[i] <== or[i].out;
        } 
        else {   
            out[i] <== or[i].out + or[i-1].carry;
        }
    }
}

component main = strAdd(256);



