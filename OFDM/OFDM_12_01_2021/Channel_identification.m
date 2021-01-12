 Options = tfestOptions;           
 Options.Display = 'on';           
 Options.WeightingFilter = [];     

                                   


response = load('output/tf_response.mat');
response = response.tf_data;
tf_t = 1:1:length(response);
figure
plot(tf_t,real(response))
hold on
input(1:18)=0; input(19:length(response)) = 0.5;
input = input';
plot(tf_t,input)

mydata = iddata(response,input);                                 
tf3 = tfest(mydata, 3, 1, Options);
fast = 0.1; 
Ginv = (1/tf3)*tf(1,[fast^2 2*fast 1])


