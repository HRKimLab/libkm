function oG = preprocess_photometry(rawG, rawR, varargin)
% PREPROCESS_PHOTOMETRY preprocess photometry voltage signal
%  This assumes that rawG is raw voltage signal sampled at 1kHz.
%  if your signal is other than 1kHz, resample it using resample()
%  function and use this routine.
% 
%  This preprocess photometry signal using two method. 
%   1) detect baseline (slow drift), subtract, zscore            : oG(1:4,:)
%   2) compute best-fit of red to green and get residual, zscore : oG(5:6,:)
% 
% preprocess_photometry(rawG, rawR, method)
%   rawG, rawR is [1, # of samples] photometry data (sampled at 1kHz).
%   rawR can be omitted or []. 
%
% preprocess_photometry(rawG, rawR, method, varargin)
%   'debug', 1: plot internal variables
%
% RETURN VALUES:
%  outG : [6, # of samples]
%    1: zscored green channel after drift correction
%    2: zscored red channel after drift correction
%    3: raw green channel
%    4: raw red channel
%    5: zscored residual from regression (best-fit of red on green)
%    6: raw residual
%
% 2023 HRK


debug = 0;      % 1: plot internal variables
pctBase = 10;   % for slow drift correction method, use 10% lowest baseline by default.

% sampling frequency is 1kHz
Fs = 1000;

process_varargin(varargin);

% if rawR is not given, use zeros
if ~is_arg('rawR')
   rawR = zeros(size(rawG)); 
end

% make sure that rawG, rawG are column vectors
assert(size(rawG, 1) == 1, 'rawG should be row vector [1, # sample]');
assert(size(rawR, 1) == 1, 'rawR should be row vector [1, # sample]');
% make sure that rawG length is the same as rawR
assert(size(rawR, 2) == size(rawG, 2), 'length of rawR and rawG should be same.');

%% apply 60Hz notch filter if DSP toolbox exists
vG = rawG;
vR = rawR;
bValidSignal = true(size(rawG));

if ~isempty(ver('DSP'))
    fprintf(1, 'DSP toolbox found. Apply 60Hz notch filter ... ');
    F0 = 60;   % interference is at 60 Hz
    f = fdesign.notch('N,F0,Q',2,F0,10,Fs);
    H = design(f);
    vG(bValidSignal) = filter(H, rawG(bValidSignal));
    vR(bValidSignal) = filter(H, rawR(bValidSignal));
    disp('done.');
else
    % change error() to warning() if you do not have 60Hz noise
    error('DSP toolbox not found. Do not apply 60Hz notch filter');
end

%% slow drift correction method
% get baseline of the signal. baseline is defined as the 
% lowest pctBase of signal in the moving 2min (120,000 ms) time window.
% This version only looks at signals during ITI. 
% more accurate, but requires additional info.
% [baseG tmp] = get_photometry_baseline(vG, 120000, pctBase, 0);
% [baseR tmp2] = get_photometry_baseline(vR, 120000, pctBase, 0);
% use simple version. This looks at both TI and ITI.
[baseG tmp] = get_photometry_baseline_simple(vG, 120000, pctBase, 0);
[baseR tmp2] = get_photometry_baseline_simple(vR, 120000, pctBase, 0);


% zscore baseline-substracted signals
oG(1, :) = nanzscore( rawG - baseG );
oG(2, :) = nanzscore( rawR - baseR );
% raw signals (60Hz filtered)
oG(3, :) = rawG;
oG(4, :) = rawR;

%% regression-based baseline correction
b = regress(vG(bValidSignal)', [vR(bValidSignal)' ones(nnz(bValidSignal), 1) (1:nnz(bValidSignal))']);
% obtain best fit from regression
fit_baseG = ( [vR' ones(size(vR')) (1:numel(vR))'] * b )';
% compute residual
resG = vG - fit_baseG;

% zscore residual signals
oG(5, :) = nanzscore(resG); 
oG(6, :) = resG; 

%% plot internal variables (signals)
if debug
   fid = figure;
   % subsample for fast plot
   i_samples = 1:10:numel(vG); 
   t_time = (1:numel(vG))/Fs;
   
   subplot(6,1,1);
   plot(t_time(i_samples) , vG(i_samples), 'color', [0 1 0]);
   hold on;
   plot(t_time(i_samples), baseG(i_samples), 'color', [0 .3 0]);
   xlabel('Time'); ylabel('Signal (V)');
   title('Green raw signal and baseline'); legend('Raw','Base');
   
   subplot(6,1,2);
   plot(t_time(i_samples),oG(1, i_samples), 'color', [0 1 0]);
   xlabel('Time'); ylabel('Signal (zscore)');
   title('Green, zscored signal');
   
   subplot(6,1,3);
   plot(t_time(i_samples),vR(i_samples), 'color', [1 0 0]);
   hold on;
   plot(t_time(i_samples),baseR(i_samples), 'color', [.3 0 0]);
   title('Red raw signal and baseline'); legend('Raw','Base');
   ylabel('Signal (V)');
   
   subplot(6,1,4);
   plot(t_time(i_samples),oG(2, i_samples), 'color', [1 0 0]);
   ylabel('Signal (zscore)');
   title('Red, zscored signal');
   
   subplot(6,1,5);
   plot(t_time(i_samples),vG(i_samples), 'color', [0 1 0]);
   hold on;
   plot(t_time(i_samples),fit_baseG(i_samples), 'color', [0 .3 0]);
   ylabel('Signal (V)');
   legend('Raw','Fitted base');
   title('Green raw signal and Red fitted to Green for baseline');
   
   subplot(6,1,6);
   plot(t_time(i_samples),oG(5, i_samples), 'color', [0 1 0]);
   ylabel('Signal (zscore)');
   xlabel('Time'); 
   title('Green, residual from the above is zscored');
   
   axs = findobj(gcf,'type','axes');
   set(axs(2:6),'xticklabel',[]);
   linkaxes(axs,'x');
end