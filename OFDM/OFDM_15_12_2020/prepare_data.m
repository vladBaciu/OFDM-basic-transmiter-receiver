% load_var = load('tx_data.mat');
% tx_data = load_var.save_data_tx;
% data_to_send = resample(tx_data,4,1);
% 
% save('tx_data_oversampled4','data_to_send');

load_var = load('feedback/rx_data_oversampled4_B.mat');
tx_data = load_var.rcvdSignal;
rcvdSignal = downsample(tx_data,4);

save('rx_data_downsampled4_B','rcvdSignal');
