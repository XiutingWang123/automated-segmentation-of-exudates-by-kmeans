function theta=logisticRegression()
% logistic regression的参数theta,可以用matlab自带函数glmfit求出
x = [0.0 0.1 0.7 1.0 1.1 1.3 1.4 1.7 2.1 2.2]';
y = [0 0 1 0 0 0 1 1 1 1]'; 
theta = glmfit(x, [y ones(10,1)], 'binomial', 'link', 'logit')
end