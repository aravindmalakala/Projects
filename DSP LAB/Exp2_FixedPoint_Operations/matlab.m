clc;
clear;
close all;

% LOAD OPERANDS (FIXED POINT INTEGERS)
q314 = load('x_q314.txt');   % Q(3,14)
q512 = load('x_q512.txt');   % Q(5,12)

%MATLAB FIXED-POINT OPERATIONS FIRST 
% Align q512 to Q(6,14) before add/sub
q512_aligned = q512 * 2^2;   % shift left by 2

% Addition & subtraction (still integers)
add_fix = q314 + q512_aligned;
sub_fix = q314 - q512_aligned;

% Multiplication (fixed-point)
mul_fix = q314 .* q512;      % integer multiply

% NOW CONVERT TO FLOAT
add_ref = add_fix / 2^14;    % Q(6,14)
sub_ref = sub_fix / 2^14;    % Q(6,14)
mul_ref = mul_fix / 2^26;    % Q(9,26)

% LOAD VERILOG OUTPUTS
ver_add = load('sum_q614.txt') / 2^14;
ver_sub = load('sub_q614.txt') / 2^14;
ver_mul = load('mul_q926.txt') / 2^26;

% TAKE FIRST 240 SAMPLES
add_ref = add_ref(1:240);
sub_ref = sub_ref(1:240);
mul_ref = mul_ref(1:240);

ver_add = ver_add(1:240);
ver_sub = ver_sub(1:240);
ver_mul = ver_mul(1:240);

% PLOTS

figure;
plot(add_ref,'b'); hold on;
plot(ver_add,'r--');
grid on;
legend('MATLAB Fixed','Verilog');
title('Addition (Fixed → Float)');

figure;
plot(sub_ref,'b'); hold on;
plot(ver_sub,'r--');
grid on;
legend('MATLAB Fixed','Verilog');
title('Subtraction (Fixed → Float)');

figure;
plot(mul_ref,'b'); hold on;
plot(ver_mul,'r--');
grid on;
legend('MATLAB Fixed','Verilog');
title('Multiplication (Fixed → Float)');
