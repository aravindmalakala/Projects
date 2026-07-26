clc; clearvars; close all

% parameters
f  = 1000;
fs = 48000;
t  = 0:1/fs:1-1/fs;

% Load Verilog data
x       = load('x.txt');
x_2_14  = load('x_2_14.txt');
x_4_12  = load('x_4_12.txt');
x_8_4   = load('x_8_4.txt');

err_2_14 = load('err_2_14.txt');
err_4_12 = load('err_4_12.txt');
err_8_4  = load('err_8_4.txt');

% Plot original signal
figure;
plot(t, x, '*');
xlabel('Time');
ylabel('Sampling of Sinewave for fs = 48k');
title('Sinewave Signal');
grid on;
xlim([0 5/f]);
ylim([-2 2]);

% Plot quantized vs original
figure;

subplot(3,1,1)
plot(t, x, 'y.'); hold on
plot(t, x_2_14, 'r.')
title('Original vs Q(2,14)')
legend('Original','Q(2,14)')
grid on
xlim([0 5/f]); ylim([-2.5 2.5])

subplot(3,1,2)
plot(t, x, 'y.'); hold on
plot(t, x_4_12, 'g.')
title('Original vs Q(4,12)')
legend('Original','Q(4,12)')
grid on
xlim([0 5/f])
ylim([-2.5 2.5])

subplot(3,1,3)
plot(t, x, 'y.'); hold on
plot(t, x_8_4, 'b.')
title('Original vs Q(8,4)')
legend('Original','Q(8,4)')
xlabel('Time (s)')
grid on
xlim([0 5/f])
ylim([-2.5 2.5])

% Plot errors
figure;

subplot(3,1,1)
plot(t, err_2_14, 'r')
title('Error Q(2,14)')
grid on
xlim([0 5/f])

subplot(3,1,2)
plot(t, err_4_12, 'g')
title('Error Q(4,12)')
grid on
xlim([0 5/f])

subplot(3,1,3)
plot(t, err_8_4, 'b')
title('Error Q(8,4)')
grid on
xlim([0 5/f])

% SQNR calculation
SQNR_2_14 = mean(abs(x).^2) / mean(abs(err_2_14).^2);
SQNR_4_12 = mean(abs(x).^2) / mean(abs(err_4_12).^2);
SQNR_8_4  = mean(abs(x).^2) / mean(abs(err_8_4).^2);

fprintf('SQNR for Q(2,14): %.2f dB\n', 10*log10(SQNR_2_14));
fprintf('SQNR for Q(4,12): %.2f dB\n', 10*log10(SQNR_4_12));
fprintf('SQNR for Q(8,4): %.2f dB\n', 10*log10(SQNR_8_4));
