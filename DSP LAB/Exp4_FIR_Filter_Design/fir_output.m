clc;
clearvars;
close all;

% Filter Coefficients
fs = 10000;
fc = 1000;
n_taps = 100;

% Normalize cutoff frequency by Nyquist frequency (Fs/2)
Wn = fc/(fs/2);

% Design a low-pass FIR filter
b = fir1(n_taps-1, Wn);

% Converting into Q(2,14)
b_q = round(b * 2^14);
b_q = max(-32768, min(32767, b_q));

% Storing the filter coefficients in a file
fid = fopen('filter_coeff_q214.txt','w');
fprintf(fid,'%d\n',b_q);
fclose(fid);

% Generate 3 sinewaves
N = 1000;
t = (0:N-1)/fs;

sinewave1 = sin(2*pi*950*t);
sinewave2 = sin(2*pi*1100*t);
sinewave3 = sin(2*pi*2000*t);

% Convert signals into Q(2,14)
sinewave1_q = round(sinewave1 * 2^14);
sinewave1_q = max(-32768, min(32767, sinewave1_q));

sinewave2_q = round(sinewave2 * 2^14);
sinewave2_q = max(-32768, min(32767, sinewave2_q));

sinewave3_q = round(sinewave3 * 2^14);
sinewave3_q = max(-32768, min(32767, sinewave3_q));

% Store signals
fid1 = fopen('sinewave1_q214.txt','w');
fprintf(fid1,'%d\n',sinewave1_q);
fclose(fid1);

fid2 = fopen('sinewave2_q214.txt','w');
fprintf(fid2,'%d\n',sinewave2_q);
fclose(fid2);

fid3 = fopen('sinewave3_q214.txt','w');
fprintf(fid3,'%d\n',sinewave3_q);
fclose(fid3);


% Direct FIR (integer arithmetic same as Verilog)
y1_dir = zeros(1,N);
y2_dir = zeros(1,N);
y3_dir = zeros(1,N);

for n = 1:N
    acc1 = 0;
    acc2 = 0;
    acc3 = 0;

    for k = 1:n_taps
        if (n-k+1) > 0
            acc1 = acc1 + sinewave1_q(n-k+1)*b_q(k);
            acc2 = acc2 + sinewave2_q(n-k+1)*b_q(k);
            acc3 = acc3 + sinewave3_q(n-k+1)*b_q(k);
        end
    end

    y1_dir(n) = acc1;
    y2_dir(n) = acc2;
    y3_dir(n) = acc3;
end


% Optimized FIR (symmetric coefficients)
half = n_taps / 2;

for n = 1:N
    acc1 = 0; acc2 = 0; acc3 = 0;

    for k = 1:half

        x1 = 0; x2 = 0;
        if (n-k+1) > 0
            x1 = sinewave1_q(n-k+1);
        end
        if (n-n_taps+k) > 0
            x2 = sinewave1_q(n-n_taps+k);
        end
        acc1 = acc1 + b_q(k)*(x1+x2);


        x1 = 0; x2 = 0;
        if (n-k+1) > 0
            x1 = sinewave2_q(n-k+1);
        end
        if (n-n_taps+k) > 0
            x2 = sinewave2_q(n-n_taps+k);
        end
        acc2 = acc2 + b_q(k)*(x1+x2);


        x1 = 0; x2 = 0;
        if (n-k+1) > 0
            x1 = sinewave3_q(n-k+1);
        end
        if (n-n_taps+k) > 0
            x2 = sinewave3_q(n-n_taps+k);
        end
        acc3 = acc3 + b_q(k)*(x1+x2);

    end

    y1_opt(n) = acc1;
    y2_opt(n) = acc2;
    y3_opt(n) = acc3;
end

% Save outputs for verification
fid = fopen('direct_950.txt','w'); fprintf(fid,'%d\n',y1_dir); fclose(fid);
fid = fopen('direct_1100.txt','w'); fprintf(fid,'%d\n',y2_dir); fclose(fid);
fid = fopen('direct_2000.txt','w'); fprintf(fid,'%d\n',y3_dir); fclose(fid);

fid = fopen('optimized_950.txt','w'); fprintf(fid,'%d\n',y1_opt); fclose(fid);
fid = fopen('optimized_1100.txt','w'); fprintf(fid,'%d\n',y2_opt); fclose(fid);
fid = fopen('optimized_2000.txt','w'); fprintf(fid,'%d\n',y3_opt); fclose(fid);



% Convert to floating point for plotting
output1_dir = y1_dir / 2^28;
output2_dir = y2_dir / 2^28;
output3_dir = y3_dir / 2^28;

output1_opt = y1_opt / 2^28;
output2_opt = y2_opt / 2^28;
output3_opt = y3_opt / 2^28;


% Plot outputs

figure;

subplot(3,1,1)
plot(t,output1_dir)
hold on
plot(t,output1_opt,'--')
title('950 Hz Output')
legend('Direct','Optimized')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([0 0.05])

subplot(3,1,2)
plot(t,output2_dir)
hold on
plot(t,output2_opt,'--')
title('1100 Hz Output')
legend('Direct','Optimized')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([0 0.05])

subplot(3,1,3)
plot(t,output3_dir)
hold on
plot(t,output3_opt,'--')
title('2000 Hz Output')
legend('Direct','Optimized')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([0 0.05])