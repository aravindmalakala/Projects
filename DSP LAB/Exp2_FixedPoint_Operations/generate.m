clc;
clear;
close all;

% PARAMETERS
N  = 48000;
FS = 48000;

% GENERATE SIGNAL
t = (0:N-1)'/FS;
x = 2*sin(2*pi*1000*t);

% FIXED POINT CONVERSION

% Q(3,14)
q314 = round(x * 2^14);
q314(q314 > 131071) = 131071;
q314(q314 < -131072) = -131072;

% Q(5,12)
q512 = round(x * 2^12);
q512(q512 > 524287) = 524287;
q512(q512 < -524288) = -524288;

% SAVE FILES FOR VERILOG
fid1 = fopen('x_q314.txt','w');
fid2 = fopen('x_q512.txt','w');

fprintf(fid1,'%d\n',q314);
fprintf(fid2,'%d\n',q512);

fclose(fid1);
fclose(fid2);

disp('Input files generated: x_q314.txt, x_q512.txt');
