clc;
clearvars;
close all;

% Parameters
N = 1000;
fs = 10000;
t = (0:N-1)/fs;

%% MATLAB outputs

fid = fopen('direct_950.txt','r');
y1_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('direct_1100.txt','r');
y2_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('direct_2000.txt','r');
y3_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('optimized_950.txt','r');
y1_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('optimized_1100.txt','r');
y2_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('optimized_2000.txt','r');
y3_opt = fscanf(fid,'%d',N)'; fclose(fid);

%% Verilog outputs (Non-pipeline)

fid = fopen('output_direct1_q214.txt','r');
v1_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_direct2_q214.txt','r');
v2_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_direct3_q214.txt','r');
v3_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_optimized1_q214.txt','r');
v1_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_optimized2_q214.txt','r');
v2_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_optimized3_q214.txt','r');
v3_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_genvar1_q214.txt','r');
v1_gen = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_genvar2_q214.txt','r');
v2_gen = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_genvar3_q214.txt','r');
v3_gen = fscanf(fid,'%d',N)'; fclose(fid);

%% Verilog outputs (Pipeline)

fid = fopen('output_direct_pipeline1_q214.txt','r');
vp1_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_direct_pipeline2_q214.txt','r');
vp2_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_direct_pipeline3_q214.txt','r');
vp3_dir = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_optimized_pipeline1_q214.txt','r');
vp1_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_optimized_pipeline2_q214.txt','r');
vp2_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_optimized_pipeline3_q214.txt','r');
vp3_opt = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_genvar_pipeline1_q214.txt','r');
vp1_gen = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_genvar_pipeline2_q214.txt','r');
vp2_gen = fscanf(fid,'%d',N)'; fclose(fid);

fid = fopen('output_genvar_pipeline3_q214.txt','r');
vp3_gen = fscanf(fid,'%d',N)'; fclose(fid);

%% Convert to floating point

output1_dir = y1_dir / 2^28;
output2_dir = y2_dir / 2^28;
output3_dir = y3_dir / 2^28;

output1_opt = y1_opt / 2^28;
output2_opt = y2_opt / 2^28;
output3_opt = y3_opt / 2^28;

vout1_dir = v1_dir / 2^28;
vout2_dir = v2_dir / 2^28;
vout3_dir = v3_dir / 2^28;

vout1_opt = v1_opt / 2^28;
vout2_opt = v2_opt / 2^28;
vout3_opt = v3_opt / 2^28;

vout1_gen = v1_gen / 2^28;
vout2_gen = v2_gen / 2^28;
vout3_gen = v3_gen / 2^28;

vpout1_dir = vp1_dir / 2^28;
vpout2_dir = vp2_dir / 2^28;
vpout3_dir = vp3_dir / 2^28;

vpout1_opt = vp1_opt / 2^28;
vpout2_opt = vp2_opt / 2^28;
vpout3_opt = vp3_opt / 2^28;

vpout1_gen = vp1_gen / 2^28;
vpout2_gen = vp2_gen / 2^28;
vpout3_gen = vp3_gen / 2^28;

%% MATLAB vs Verilog Direct

figure;
subplot(3,1,1)
plot(t,output1_dir); hold on
plot(t,vout1_dir,'--')
title('950 Hz Output')
legend('MATLAB','Verilog Direct')
xlim([0 0.05])

subplot(3,1,2)
plot(t,output2_dir); hold on
plot(t,vout2_dir,'--')
title('1100 Hz Output')
legend('MATLAB','Verilog Direct')
xlim([0 0.05])

subplot(3,1,3)
plot(t,output3_dir); hold on
plot(t,vout3_dir,'--')
title('2000 Hz Output')
legend('MATLAB','Verilog Direct')
xlim([0 0.05])

%% Direct Pipeline

figure;
subplot(3,1,1)
plot(t,output1_dir); hold on
plot(t,vpout1_dir,'--')
title('950 Hz Direct Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

subplot(3,1,2)
plot(t,output2_dir); hold on
plot(t,vpout2_dir,'--')
title('1100 Hz Direct Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

subplot(3,1,3)
plot(t,output3_dir); hold on
plot(t,vpout3_dir,'--')
title('2000 Hz Direct Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

%% Optimized Pipeline

figure;
subplot(3,1,1)
plot(t,output1_opt); hold on
plot(t,vpout1_opt,'--')
title('950 Hz Optimized Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

subplot(3,1,2)
plot(t,output2_opt); hold on
plot(t,vpout2_opt,'--')
title('1100 Hz Optimized Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

subplot(3,1,3)
plot(t,output3_opt); hold on
plot(t,vpout3_opt,'--')
title('2000 Hz Optimized Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

%% Genvar Pipeline

figure;
subplot(3,1,1)
plot(t,output1_dir); hold on
plot(t,vpout1_gen,'--')
title('950 Hz Genvar Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

subplot(3,1,2)
plot(t,output2_dir); hold on
plot(t,vpout2_gen,'--')
title('1100 Hz Genvar Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])

subplot(3,1,3)
plot(t,output3_dir); hold on
plot(t,vpout3_gen,'--')
title('2000 Hz Genvar Pipeline')
legend('MATLAB','Verilog Pipeline')
xlim([0 0.05])