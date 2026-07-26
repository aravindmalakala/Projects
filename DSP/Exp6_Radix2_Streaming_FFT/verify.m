%% Compare Verilog vs MATLAB FFT outputs (stem plots, markers only)
clear; clc;

SCALE = 32;
N = 8;
bitrev = [0, 4, 2, 6, 1, 5, 3, 7];   % bit-reversal for N=8

for c = 1:3
    % Load and scale Verilog (bit-reversed) -> natural order
    v = load(sprintf('verilog_output_case%d.txt', c));
    v_cplx = (v(:,1) + 1i*v(:,2)) / SCALE;
    v_nat = v_cplx(bitrev+1);
    
    % Load and scale MATLAB (natural order)
    m = load(sprintf('matlab_output_case%d.txt', c));
    m_cplx = (m(:,1) + 1i*m(:,2)) / SCALE;
    
    % Create figure
    figure('Name', sprintf('Case %d', c), 'Position', [100+50*(c-1), 100, 550, 750]);
    
    % Real part
    subplot(3,1,1);
    stem(0:N-1, real(v_nat), 'b--o', 'LineWidth', 1, 'MarkerSize', 6, 'DisplayName', 'Verilog');
    hold on;
    stem(0:N-1, real(m_cplx), 'r-.x', 'LineWidth', 1, 'MarkerSize', 8, 'DisplayName', 'MATLAB');
    grid on; xlabel('Bin index'); ylabel('Real');
    title('Real part (÷32)'); legend('Location','best');
    
    % Imag part
    subplot(3,1,2);
    stem(0:N-1, imag(v_nat), 'b--o', 'LineWidth', 1, 'MarkerSize', 6, 'DisplayName', 'Verilog');
    hold on;
    stem(0:N-1, imag(m_cplx), 'r-.x', 'LineWidth', 1, 'MarkerSize', 8, 'DisplayName', 'MATLAB');
    grid on; xlabel('Bin index'); ylabel('Imag');
    title('Imag part (÷32)'); legend('Location','best');
    
    % Magnitude
    subplot(3,1,3);
    stem(0:N-1, abs(v_nat), 'b--o', 'LineWidth', 1, 'MarkerSize', 6, 'DisplayName', 'Verilog');
    hold on;
    stem(0:N-1, abs(m_cplx), 'r-.x', 'LineWidth', 1, 'MarkerSize', 8, 'DisplayName', 'MATLAB');
    grid on; xlabel('Bin index'); ylabel('Magnitude');
    title('Magnitude (÷32)'); legend('Location','best');
    
    sgtitle(sprintf('Case %d: %s', c, caseName(c)), 'FontWeight','bold');
end

function s = caseName(c)
    switch c
        case 1, s = 'Impulse';
        case 2, s = 'DC';
        case 3, s = 'Sine wave';
    end
end