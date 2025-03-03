function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% Add ones to the X data matrix
a1 = [ones(m, 1) X];

% y is a vector where each component represents the correct label, i.e.
% what number is represented by the 30x30 pixel image.
%
% y_matrix is a matrix in which each row is a binary vector with dimension
% num_labels. For example, for a three-class classifier, the output from
% the neural network would be a vector [1,0,0], [0,1,0], or [0,0,1]
% depending on the predicted class.
temp = eye(num_labels);
y_matrix = temp(y,:);

% Forwared propagation (compute cost)
% -------------------------------------------------------------------------
z2 = a1 * Theta1';
a2 = sigmoid(z2);

% Add bias units to middle activation units.
a2 = [ones(m, 1) a2];
z3 = a2 * Theta2';
a3 = sigmoid(z3);

% I realize this semantic, but just to be clear: a3 is the hypothesis.
hyp = a3;

% Cost is a scalar, so we take the sum twice. This looks cleaner than the 
% mathmetical notation because the indices are implicit in the size of the
% matrix.
% 
% First, we sum the columns, giving us a row vector. Since we're dealing
% with an (m x num_labels) vector, the result is a (num_labels)-vector
% where each component is the sum of the column. Taking the sum again
% generates a scalar. Notice that this is the opposite order of the
% mathematical notation, but order of operations does not matter for
% addition.
J = sum(sum((-y_matrix .* log(hyp)) - ((1-y_matrix) .* log(1 - hyp)))) / m;


% Regularized cost
% -------------------------------------------------------------------------

% Don't regularize the bias unit.
Theta1_ = Theta1(:,2:end);
Theta2_ = Theta2(:,2:end);
reg_term = (lambda / (2*m)) * (sum(sum(Theta1_.^2)) + sum(sum(Theta2_.^2)));
J = J + reg_term;


% Backpropagation (compute gradienet)
% -------------------------------------------------------------------------

% The initial error: the hypothesis minus the computed values.
d3 = hyp - y_matrix;
Theta2_ = Theta2(:,2:end);
d2 = (d3 * Theta2_) .* sigmoidGradient(z2);

% The accumulation that is explicit in a for-loop implementation is
% implicit in these matrix-matrix multiplications.
Delta1 = d2' * a1;
Delta2 = d3' * a2;

Theta1_grad = Delta1 / m;
Theta2_grad = Delta2 / m;


% Regularized gradient
% -------------------------------------------------------------------------

% We can mutate Theta1 and Theta2. We don't need them any more.
% We're setting the first columns to 0, i.e. not regularizing the the bias
% unit.
Theta1(:,1) = 0;
Theta2(:,1) = 0;

reg_term1 = (lambda / m) * Theta1;
reg_term2 = (lambda / m) * Theta2;

Theta1_grad = Theta1_grad + reg_term1;
Theta2_grad = Theta2_grad + reg_term2;


% Unroll gradients
% -------------------------------------------------------------------------
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
