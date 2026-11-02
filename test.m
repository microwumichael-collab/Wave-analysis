clear; clc; close all;

%% 1. Load Data
load('Data_Fig2.mat'); % Spectrum
load('Data_Fig1.mat'); % Recorded Wave

d = 30; 
g = 9.81; 

%% 2. Prepare Spectrum (Using Friend's Frequency Filter)
% Transpose to row vectors to match friend's code structure
f = f(:)';
amp = amp(:)';
phase = phase(:)';

% --- THE CRITICAL FIX: FREQUENCY FILTER ---
% Your friend filters purely by frequency range, not amplitude.
idx = f >= 0.03 & f <= 0.3;

spec.f     = f(idx);
spec.a     = amp(idx);
spec.ph    = phase(idx);
spec.d     = d;
spec.omega = 2 * pi * spec.f;
spec.th    = zeros(size(spec.f)); % Assume unidirectional

% Calculate wavenumbers for ONLY the kept frequencies
spec.k = fDispersion(d, 1./spec.f);

%% 3. Generate Elevation (2nd Order Total)
t = linspace(-60, 60, 2400); % Keep your long time window to find the peak
x = 0; 
y = 0;

% Calculate TOTAL elevation (1st + 2nd Order) using only the clean, filtered waves
eta_total = fSecRndEta(x, y, t, spec);

% Also calculate 1st order (linear) for the filtered set just for comparison
eta_linear = zeros(size(t));
for n = 1:length(spec.f)
    eta_linear = eta_linear + spec.a(n) * cos(spec.omega(n)*t + spec.ph(n));
end

%% 4. Velocity Profile (Using Filtered Spectrum)
% Find the crest time of the 2nd order wave
[max_val, idx_crest] = max(eta_total);
t_crest = t(idx_crest);

% Define z vector under the crest
z_vec = linspace(-d, max_val, 100);

% Calculate velocity profile at the exact moment of the crest
[u, v, w] = fSecRndVel(x, y, z_vec, t_crest, spec);

% Important: fSecRndVel might return a matrix. We want the column corresponding to t_crest.
% Since we passed a scalar t_crest, u should be a vector. If not, check dimensions.

%% 5. Alignment for Plotting
% Align Recorded Data
[max_rec, idx_rec] = max(eta_max_wave);
t_rec_shifted = t_max_wave - t_max_wave(idx_rec);

% Align Simulation
t_sim_shifted = t - t_crest;

%% 6. Plotting (Sample Code Layout)
figure('Position', [100, 100, 1200, 500]);

% --- Left Panel: Surface Elevation (Spans 2 columns) ---
subplot(1, 3, 1:2);
plot(t_rec_shifted, eta_max_wave, 'k-', 'LineWidth', 2, 'DisplayName', 'Recorded Data');
hold on; grid on;
plot(t_sim_shifted, eta_linear, 'b--', 'LineWidth', 1.5, 'DisplayName', '1st Order (Filtered)');
plot(t_sim_shifted, eta_total, 'r-', 'LineWidth', 1.5, 'DisplayName', '2nd Order (Filtered)');

xlim([-10 10]);
ylim([min(eta_max_wave)*1.2, max(eta_max_wave)*1.2]);
xlabel('Time [s]', 'FontWeight', 'bold'); 
ylabel('Elevation \eta [m]', 'FontWeight', 'bold');
title('Random Wave Elevation Comparison (0.03 - 0.3 Hz)');
legend('Location', 'northeast');

% --- Right Panel: Velocity Profile (Spans 1 column) ---
subplot(1, 3, 3);
plot(u, z_vec, 'b-', 'LineWidth', 2, 'DisplayName', 'Horizontal Velocity u');
hold on; grid on;

yline(0, 'k-', 'HandleVisibility', 'off'); % MWL
yline(max_val, 'k:', 'HandleVisibility', 'off'); % Crest

xlabel('Velocity u [m/s]', 'FontWeight', 'bold'); 
ylabel('Elevation z [m]', 'FontWeight', 'bold');
title('Velocity Profile at Crest');
legend('Location', 'southeast');

%% 7. Error Check
fprintf('\n--- CREST ERROR ---\n');
fprintf('2nd Order Error: %.2f%%\n', 100 * abs(max_rec - max(eta_total)) / max_rec);