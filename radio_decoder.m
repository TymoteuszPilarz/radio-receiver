% Matlab program demonstrating conventional FM radio broadcast decoding (mono audio, stereo audio, RDS).
% 05.01.2024 Tymoteusz Pilarz, tymoteuszpilarz@gmail.com

clear all;

%% Receiver parameters
audio_mode = 2; % Audio mode: 0 - off, 1 - mono, 2 - stereo

f_carr = 96e6;
f_samp = 250e3;
f_samp_audio = 25e3;

f_pilot = 19e3;
f_symb = f_pilot / 16;
f_stereo = 2 * f_pilot;
f_rds = 3 * f_pilot;

buffer_size = 24000;

%% Filters setup
filt_length = 500;
filt_delay = filt_length / 2;

% Wide low-pass filter for separation the mono signal
hLPaudio = fir1(filt_length, (f_samp_audio / 2)/(f_samp / 2), kaiser(filt_length+1, 7));

% Narrow band-pass filter for separation of the pilot signal (around 19 kHz)
fcentr = f_pilot;
df1 = 1000;
df2 = 2000;
ff = [0, fcentr - df2, fcentr - df1, fcentr + df1, fcentr + df2, f_samp / 2] / (f_samp / 2);
fa = [0, 0.01, 1, 1, 0.01, 0];
hBP19 = firls(filt_length, ff, fa);

% Wide band-pass filter for separation of the stereo signal (around 38 kHz)
fcentr = f_stereo;
df1 = 0.8 * f_samp_audio / 2;
df2 = f_samp_audio / 2;
ff = [0, fcentr - df2, fcentr - df1, fcentr + df1, fcentr + df2, f_samp / 2] / (f_samp / 2);
fa = [0, 0.01, 1, 1, 0.01, 0];
hBP38 = firls(filt_length, ff, fa);

% Narrow band-pass filter for separation of the RDS signal (around 57 kHz)
fcentr = f_rds;
df1 = 2000;
df2 = 4000;
ff = [0, fcentr - df2, fcentr - df1, fcentr + df1, fcentr + df2, f_samp / 2] / (f_samp / 2);
fa = [0, 0.01, 1, 1, 0.01, 0];
hBP57 = firls(filt_length, ff, fa);

% Pulse shaping filter
num_of_symb = 6;
samp_per_symb = round(f_samp/f_symb);
psf_length = num_of_symb * samp_per_symb;
psf_delay = psf_length / 2;

h_psf = rcosdesign(1.0, round(psf_length/(f_samp / f_symb / 2)), ceil(f_samp/f_symb/2), 'sqrt');
h_psf = h_psf(num_of_symb/2+1:end-num_of_symb/2-1);
h_psf = h_psf / max(h_psf);

psf_phase_shift = angle(exp(-1i*2*pi*f_symb/f_samp*(0:num_of_symb * samp_per_symb - 1))*h_psf');

% RDS integrator
h_integ = ones(1, samp_per_symb) / samp_per_symb;
integ_length = length(h_integ);
integ_delay = round(samp_per_symb/2);

%% RDS parser setup
% Parity check matrix
check = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0; ...
    0, 1, 0, 0, 0, 0, 0, 0, 0, 0; ...
    0, 0, 1, 0, 0, 0, 0, 0, 0, 0; ...
    0, 0, 0, 1, 0, 0, 0, 0, 0, 0; ...
    0, 0, 0, 0, 1, 0, 0, 0, 0, 0; ...
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0; ...
    0, 0, 0, 0, 0, 0, 1, 0, 0, 0; ...
    0, 0, 0, 0, 0, 0, 0, 1, 0, 0; ...
    0, 0, 0, 0, 0, 0, 0, 0, 1, 0; ...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1; ...
    1, 0, 1, 1, 0, 1, 1, 1, 0, 0; ...
    0, 1, 0, 1, 1, 0, 1, 1, 1, 0; ...
    0, 0, 1, 0, 1, 1, 0, 1, 1, 1; ...
    1, 0, 1, 0, 0, 0, 0, 1, 1, 1; ...
    1, 1, 1, 0, 0, 1, 1, 1, 1, 1; ...
    1, 1, 0, 0, 0, 1, 0, 0, 1, 1; ...
    1, 1, 0, 1, 0, 1, 0, 1, 0, 1; ...
    1, 1, 0, 1, 1, 1, 0, 1, 1, 0; ...
    0, 1, 1, 0, 1, 1, 1, 0, 1, 1; ...
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1; ...
    1, 1, 1, 1, 0, 1, 1, 1, 0, 0; ...
    0, 1, 1, 1, 1, 0, 1, 1, 1, 0; ...
    0, 0, 1, 1, 1, 1, 0, 1, 1, 1; ...
    1, 0, 1, 0, 1, 0, 0, 1, 1, 1; ...
    1, 1, 1, 0, 0, 0, 1, 1, 1, 1; ...
    1, 1, 0, 0, 0, 1, 1, 0, 1, 1];

% Syndroms
syndrome_A = [1, 1, 1, 1, 0, 1, 1, 0, 0, 0];
syndrome_B = [1, 1, 1, 1, 0, 1, 0, 1, 0, 0];
syndrome_Ca = [1, 0, 0, 1, 0, 1, 1, 1, 0, 0];
syndrome_Cb = [1, 1, 1, 1, 0, 0, 1, 1, 0, 0];
syndrome_D = [1, 0, 0, 1, 0, 1, 1, 0, 0, 0];

programme_name = blanks(8);
radio_text = blanks(64);

%% PLL initial parameters
last_theta = 0;
last_omega = 2 * pi * f_pilot / f_samp;

%% Audio player setup
if (audio_mode ~= 0)
    player = audioDeviceWriter(f_samp_audio);
end

%% RTL-SDR receiver setup
rxsdr = comm.SDRRTLReceiver("CenterFrequency", f_carr, 'SampleRate', f_samp, 'SamplesPerFrame', buffer_size, 'OutputDataType', 'double','EnableTunerAGC', false, 'TunerGain', 40);

%% Main loop setup
prev_buffer = zeros(1, buffer_size+1);
first_iter = true;

%% Main loop
while (true)
    %% Reading iq samples (double buffer)
    current_buffer = rxsdr().';
    buffer = [prev_buffer, current_buffer];
    prev_buffer = [prev_buffer(end), current_buffer];

    if first_iter == true
        first_iter = false;
        continue
    end

    %% FM demodulation
    x = (1 / (2 * pi)) * angle(buffer(2:end).*conj(buffer(1:end-1)));

    %% Carrier recovery
    pilot = filter(hBP19, 1, x);
    pilot = pilot(filt_delay+1:end);

    theta = zeros(1, length(pilot));
    theta(1) = last_theta;
    omega = zeros(1, length(pilot));
    omega(1) = last_omega;
    mi1 = 0.0025;
    mi2 = mi1^2 / 4;
    pilot = pilot / max(abs(pilot));
    for n = 1:length(pilot) - 1
        phase_error = -pilot(n) * sin(theta(n));
        theta(n+1) = theta(n) + omega(n) + mi1 * phase_error;
        omega(n+1) = omega(n) + mi2 * phase_error;
    end
    last_theta = theta(buffer_size+1);
    last_omega = omega(buffer_size+1);

    c_symb = cos(theta/16+psf_phase_shift);
    c_stereo = cos(2*theta);
    c_rds = cos(3*theta);

    %% Mono signal decoding
    x_mono = filter(hLPaudio, 1, x);
    x_mono = x_mono(filt_delay+1:filt_delay+1+buffer_size-1);
    x_mono = resample(x_mono, f_samp_audio, f_samp);
    max_mono = max(abs(x_mono));

    %% Stereo signal decoding
    x_stereo = filter(hBP38, 1, x);
    x_stereo = x_stereo(filt_delay+1:end);
    x_stereo = x_stereo .* c_stereo;
    x_stereo = filter(hLPaudio, 1, x_stereo);
    x_stereo = x_stereo(filt_delay+1:filt_delay+1+buffer_size-1);
    x_stereo = 2 * resample(x_stereo, f_samp_audio, f_samp);
    x_stereo_left = 0.5 * (x_mono + x_stereo);
    x_stereo_rigth = 0.5 * (x_mono - x_stereo);
    max_stereo = max(max(abs(x_stereo_left)), max(abs(x_stereo_rigth)));

    %% RDS decoding
    rds = filter(hBP57, 1, x);
    rds = rds(filt_delay+1:end);
    rds = rds .* c_rds;
    rds = filter(h_psf, 1, rds);
    rds = rds(psf_delay+1:end);
    c_symb = c_symb(psf_delay+1:end);

    % Clock recovery
    shift_step = round(f_samp/f_pilot);
    max_shift = floor(f_samp/f_symb);
    corr_length = length(rds) - max_shift;
    corr = zeros(1, floor(max_shift/shift_step)+1);
    for n = 1:length(corr)
        shift = (n - 1) * shift_step;
        corr(n) = sum(rds(1+shift:1+shift+corr_length-1).*c_symb(1:corr_length));
    end
    [~, shift] = max(corr);
    shift = (shift - 1) * shift_step;
    rds = rds(1+shift:end);
    c_symb = c_symb(1:end-shift);

    % Coherent detection
    rds = rds .* c_symb;
    rds = rds / max(rds);

    % RDS integration
    rds = filter(h_integ, 1, rds);
    rds = rds(integ_delay+1:end);
    c_symb = c_symb(integ_delay+1:end);

    % Finding zero-crossings
    slope_samp = 5;
    slope_dev_samp = (slope_samp - 1) / 2;
    symb_indx1 = [];
    symb_indx2 = [];
    for n = slope_dev_samp + 1:length(c_symb) - slope_dev_samp
        if ((c_symb(n-2) > 0) && (c_symb(n-1) > 0) && (c_symb(n+1) < 0) && (c_symb(n+2) < 0))
            symb_indx1 = [symb_indx1, n];
        end
        if ((c_symb(n-2) < 0) && (c_symb(n-1) < 0) && (c_symb(n+1) > 0) && (c_symb(n+2) > 0))
            symb_indx2 = [symb_indx2, n];
        end
    end
    if (std(rds(symb_indx1)) > std(rds(symb_indx2)))
        symb_indx = symb_indx1;
    else
        symb_indx = symb_indx2;
    end

    % Decoding bits
    rds_bits_diff = (-sign(rds(symb_indx)) + 1) / 2;
    rds_bits = abs(rds_bits_diff(2:end)-rds_bits_diff(1:end-1));
    rds_bits = rds_bits(2:2:end);

    %% Parsing RDS bits
    for n = 1:104
        syndrome = calc_syndrome(n, rds_bits, check);
        if (syndrome == syndrome_A)
            syndrome = calc_syndrome(n+26, rds_bits, check);
            if (syndrome == syndrome_B)
                syndrome = calc_syndrome(n+52, rds_bits, check);
                if (syndrome == syndrome_Ca)
                    syndrome = calc_syndrome(n+78, rds_bits, check);
                    if (syndrome == syndrome_D)
                        [programme_name, radio_text] = process_rds(n, rds_bits, programme_name, radio_text);
                    end
                elseif (syndrome == syndrome_Cb)
                    syndrome = calc_syndrome(n+78, rds_bits, check);
                    if (syndrome == syndrome_D)
                        [programme_name, radio_text] = process_rds(n, rds_bits, programme_name, radio_text);
                    end
                end
            end
        end
    end

    %% Show RDS data
    clc;
    disp(['Programme name: ', programme_name]);
    disp(['Radio text: ', radio_text]);

    %% Play audio
    if (audio_mode == 1)
        player(x_mono.' / max_mono);
    elseif audio_mode == 2
        player([x_stereo_left.' / max_stereo, x_stereo_rigth.' / max_stereo]);
    end
end

function [programme_name, radio_text] = process_rds(n, rds_bits, programme_name, radio_text)
    block_A = rds_bits(n:n+25);
    block_B = rds_bits(n+26:n+51);
    block_C = rds_bits(n+52:n+77);
    block_D = rds_bits(n+78:n+103);

    type = block_B(1:5);

    % Group 0A or 0B
    if (type(1:4) == [0, 0, 0, 0])
        persistent programme_name_buffer;
        if isempty(programme_name_buffer)
            programme_name_buffer = blanks(64);
        end

        persistent prev_name_seg;
        if isempty(prev_name_seg)
            prev_name_seg = -1;
        end
        
        name_seg = block_B(15:16);
        first_indx = name_seg(1) * 4 + name_seg(2) * 2 + 1;
        name_seg = bin2dec(num2str(block_B(15:16)));

        if name_seg ~= 0 && name_seg ~= prev_name_seg && name_seg ~= prev_name_seg + 1
            prev_name_seg = -1;
            return;
        else
            prev_name_seg = name_seg;
        end

        ascii1 = block_D(1:8);
        ascii2 = block_D(9:16);

        char1 = char(bin2dec(num2str(ascii1)));
        char2 = char(bin2dec(num2str(ascii2)));

        chars = [char1, char2];

        programme_name_buffer(first_indx : first_indx+1) = chars;

        if (name_seg == 3)
            programme_name = programme_name_buffer;
        end

    % Group 2A
    elseif (type == [0 0 1 0 0])
        persistent radio_text_buffer;
        if isempty(radio_text_buffer)
            radio_text_buffer = blanks(64);
        end

        persistent prev_text_seg;
        if isempty(prev_text_seg)
            prev_text_seg = -1;
        end

        persistent prev_AB_flag;
        if isempty(prev_AB_flag)
            prev_AB_flag = -1;
        end

        text_seg = block_B(13:16);
        first_indx = (text_seg(1) * 8 + text_seg(2) * 4 + text_seg(3) * 2 + text_seg(4)) * 4 + 1;
        text_seg = bin2dec(num2str(text_seg));

        if (text_seg ~= 0 && text_seg ~= prev_text_seg && text_seg ~= prev_text_seg + 1)
            prev_text_seg = -1;
            prev_AB_flag = -1;
            return
        else
            prev_text_seg = text_seg;
        end

        AB_flag = block_B(12);
        
        ascii1 = block_C(1:8);
        ascii2 = block_C(9:16);
        ascii3 = block_D(1:8);
        ascii4 = block_D(9:16);
        
        char1 = char(bin2dec(num2str(ascii1)));
        char2 = char(bin2dec(num2str(ascii2)));
        char3 = char(bin2dec(num2str(ascii3)));
        char4 = char(bin2dec(num2str(ascii4)));

        chars = [char1 char2 char3 char4];

        if AB_flag ~= prev_AB_flag
            radio_text_buffer = blanks(64);
            prev_AB_flag = AB_flag;
        end

        radio_text_buffer(first_indx:first_indx+3) = chars;

        if text_seg == 15
            radio_text = radio_text_buffer;
        end
    end
end

function result = calc_syndrome(n, rds_bits, check)
    result = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    chunk = rds_bits(n:n+25);
    for bit_check = 1:26
        if (chunk(bit_check))
            result = xor(result, check(bit_check, :));
        end
    end
end
