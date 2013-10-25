% estimates a homography between geo and pixel coords

% input quad
x = [
		52.555663889 13.321519444
		52.555663889 13.426994444
		52.491488889 13.426994444
		52.491488889 13.321519444
	]

% output quad
X = [
		516	223
		1046 192
		1083 727
		532 759
	]

% design matrix
M = [];
for i = 1:size(x,1)
	M = [M;
		x(i,1) x(i,2) 1, 0 0 0, -X(i,1)*x(i,1) -X(i,1)*x(i,2)
		0 0 0, x(i,1) x(i,2) 1, -X(i,2)*x(i,1) -X(i,2)*x(i,2)
	];
end

% homography
%h = M \ X'(:);
h = inv(M) * X'(:);
H = reshape([h;1],3,3)'

csvwrite('homography.csv', H);
