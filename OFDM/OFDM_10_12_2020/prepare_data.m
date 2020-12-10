load_var = load('tx_data.mat');
tx_data = load_var.save_data_tx;
data_to_send = resample(tx_data,4,1);

save('tx_data_oversampled4','data_to_send');