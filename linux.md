# Problem Statement

1. **Create the Directory Structure:**
   - Create a directory named `projects`.
   - Inside the `projects` directory, create the following subdirectories:
     ```
     projects/facebook
     projects/google
     └── oriserve
     projects/meta
     └── oriserve
     projects/oracle
     ```

2. **Find and Modify the Directory:**
   - Find the `oriserve` directories inside the `projects` directory.
   - In each `oriserve` directory, create a file named `test.txt`.

   - The expected output should resemble the following structure:
     ```
     projects/
     ├── facebook
     ├── google
     │   └── oriserve
     │       └── test.txt
     ├── meta
     │   └── oriserve
     │       └── test.txt
     └── oracle
     ```


# Solution

# Creating Files in Specific Folders

## Step 1: Create the Directory Structure

1. Open a terminal.

![image](https://github.com/user-attachments/assets/414e2192-b258-4b71-a146-e9259a167410)

3. Use the following `mkdir` command to create a directory named `projects` and the required subdirectories with or without the `oriserve` folder:

```
mkdir -p projects/facebook projects/google/oriserve projects/meta/oriserve projects/oracle
```
![image](https://github.com/user-attachments/assets/72a70155-5bd2-4840-b191-937021c82ff9)

for seeing the folder structure i am installing tree

```
sudo apt install tree
```

![image](https://github.com/user-attachments/assets/e9ae10bc-df76-457d-902b-74981fef14d5)

folders are created 

---

## Step 2: Write the Shell Script

1. Create a new shell script file named `create_files.sh` using a text editor like `vi`:

   ```
   vi create_files.sh
   ```

2. Add the following content to the `create_files.sh` file:

   ```
   #!/bin/bash

   # Find all 'oriserve' directories under 'projects' and create 'test.txt' inside each
   find projects -type d -name "oriserve" -exec bash -c 'touch {}/test.txt' \;
   ```

![image](https://github.com/user-attachments/assets/d641f38c-355f-4f3f-a05b-1fc4c8071ad1)

3. Save the file and exit the text editor:
   - Press esc:wq
     
## Step 3: Make the Shell Script Executable

1. Run the following command to make the `create_files.sh` script executable:

   ```
   chmod +x create_files.sh
   ```
![image](https://github.com/user-attachments/assets/65a1bf22-55dc-4fb5-838e-c172c5705fed)

## Step 4: Execute the Shell Script

1. Execute the script by typing:

```
./create_files.sh
```

2. The script will find all directories named `oriserve` inside the `projects` directory and create an empty `test.txt` file inside each.

## Step 5: Verify the Output

![image](https://github.com/user-attachments/assets/e9accb5e-7094-4b4e-aefe-bb66e8c46f9c)


ls projects/google/oriserve

![image](https://github.com/user-attachments/assets/1058e403-5df3-4703-8b90-1d31b7022001)

ls projects/meta/oriserve

![image](https://github.com/user-attachments/assets/8edfdc42-e0b0-4f7e-abd6-6b4d4f6baa38)

Both commands should list the `test.txt` file.
```

