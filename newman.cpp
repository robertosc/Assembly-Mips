#include <bits/stdc++.h> 
using namespace std; 
  
// Recursive Function to find the n-th element 
int sequence(int n) 
{ 
    if (n == 0 || n == 1 || n == 2) 
        return 1; 
    else{
        int a = sequence(n-1);
        return sequence(a)  + sequence(n-a); 
    }
} 
  
// Driver Program 
int main() 
{ 
    int n = 100; 
    for (int i = 0; i<=n; i++){
    cout << sequence(i); 
    }
    return 0; 
} 