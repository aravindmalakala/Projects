clear; clc;

FRAC = 5;
SCALE = 2^FRAC;   % 32

% Case 1: Impulse at sample 0 (value 1.0)
x1 = [1, 0, 0, 0, 0, 0, 0, 0];   % real only, imag = 0

% Case 2: DC (constant 1.0)
x2 = [1, 1, 1, 1, 1, 1, 1, 1];

% Case 3: One cycle sine wave (real part)
n = 0:N-1;
x3 = sin(2*pi*1*n/N);             % real sine, imag = 0


%Compute FFT and quantize
% Case 1
x1_int = round(x1 * SCALE);
X1_float = fft(x1, N);
X1_int = round(X1_float * SCALE);

% Case 2
x2_int = round(x2 * SCALE);
X2_float = fft(x2, N);
X2_int = round(X2_float * SCALE);

% Case 3
x3_int = round(x3 * SCALE);
X3_float = fft(x3, N);
X3_int = round(X3_float * SCALE);

% ========== Write input files ==========
write_int_file('input_case1.txt', x1_int);
write_int_file('input_case2.txt', x2_int);
write_int_file('input_case3.txt', x3_int);

% ========== Write MATLAB output files ==========
wite_int_file('matlab_output_case1.txt', X1_int);
write_int_file('matlab_output_case2.txt', X2_int);
write_int_file('matlab_output_case3.txt', X3_int);

disp('Generated: input_case1.txt, input_case2.txt, input_case3.txt');
disp('Generated: matlab_output_case1.txt, matlab_output_case2.txt, matlab_output_case3.txt');

% ========== Helper function ==========
function write_int_file(filename, data)
    fileID = fopen(filename, 'w');
    for i = 1:length(data)
        fprintf(fileID, '%d %d\n', real(data(i)), imag(data(i)));
    end
    fclose(fileID);
end