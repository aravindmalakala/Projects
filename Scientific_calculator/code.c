#include <avr/io.h>
#include <util/delay.h>
#include <string.h>

#define LCD_DATA PORTB
#define LCD_RSPIN PB0
#define LCD_ENPIN PB1

#define MAX_EXPR_LENGTH 32
#define OPERATOR_COUNT 4
#define TRIG_COUNT 6  // Includes sin, cos, tan, asin, acos, atan

// Button pin definitions
#define BTN0_PIN PD0
#define BTN1_PIN PD1
#define BTN2_PIN PD2
#define BTN3_PIN PD3
#define BTN4_PIN PD4
#define BTN5_PIN PD5
#define BTN6_PIN PD6
#define BTN7_PIN PD7
#define BTN8_PIN PC0
#define BTN9_PIN PC1
#define DECIMAL_BTN_PIN PC2
#define OP_BTN_PIN PC3
#define TRIG_BTN_PIN PC4
#define ENTER_BTN_PIN PC5

// Button registers
#define BTN0_PIN_REG PIND
#define BTN1_PIN_REG PIND
#define BTN2_PIN_REG PIND
#define BTN3_PIN_REG PIND
#define BTN4_PIN_REG PIND
#define BTN5_PIN_REG PIND
#define BTN6_PIN_REG PIND
#define BTN7_PIN_REG PIND
#define BTN8_PIN_REG PINC
#define BTN9_PIN_REG PINC
#define DECIMAL_BTN_PIN_REG PINC
#define OP_BTN_PIN_REG PINC
#define TRIG_BTN_PIN_REG PINC
#define ENTER_BTN_PIN_REG PINC

// Global variables
char expression[MAX_EXPR_LENGTH + 1];
int exprIndex = 0;
int resultDisplayed = 0;
int operatorSelected = 0;
int trigSelected = 0;
int operation = 0;
int trigMode = 0;

// Function prototypes
void lcd_init(void);
void lcd_cmd(unsigned char cmd);
void lcd_data(unsigned char data);
void lcd_print(const char *str);
void init_buttons(void);
int check_button(volatile uint8_t *pin_reg, uint8_t pin);
void append_char(char c);
void update_lcd(void);
void append_operator(void);
void append_trig_function(void);
void process_enter(void);

// LCD functions

void lcd_init(void) {
    _delay_ms(15);
    lcd_cmd(0x02);  // Return home.
    lcd_cmd(0x28);  // 4-bit mode - 2 line - 5x7 font.
    lcd_cmd(0x0C);  // Display on, no cursor.
    lcd_cmd(0x06);  // Increment cursor.
    lcd_cmd(0x01);  // Clear display.
    _delay_ms(2);
}

void lcd_cmd(unsigned char cmd) {
    LCD_DATA = (LCD_DATA & 0x0F) | (cmd & 0xF0);
    LCD_DATA &= ~(1 << LCD_RSPIN);
    LCD_DATA |= (1 << LCD_ENPIN);
    _delay_us(1);
    LCD_DATA &= ~(1 << LCD_ENPIN);
    _delay_us(200);
    LCD_DATA = (LCD_DATA & 0x0F) | (cmd << 4);
    LCD_DATA |= (1 << LCD_ENPIN);
    _delay_us(1);
    LCD_DATA &= ~(1 << LCD_ENPIN);
    _delay_ms(2);
}

void lcd_data(unsigned char data) {
    LCD_DATA = (LCD_DATA & 0x0F) | (data & 0xF0);
    LCD_DATA |= (1 << LCD_RSPIN);
    LCD_DATA |= (1 << LCD_ENPIN);
    _delay_us(1);
    LCD_DATA &= ~(1 << LCD_ENPIN);
    _delay_us(200);
    LCD_DATA = (LCD_DATA & 0x0F) | (data << 4);
    LCD_DATA |= (1 << LCD_ENPIN);
    _delay_us(1);
    LCD_DATA &= ~(1 << LCD_ENPIN);
    _delay_ms(2);
}

void lcd_print(const char *str) {
    while (*str)
        lcd_data(*str++);
}

// Button functions

void init_buttons(void) {
    DDRD &= ~((1 << BTN0_PIN) | (1 << BTN1_PIN) | (1 << BTN2_PIN) | (1 << BTN3_PIN) |
              (1 << BTN4_PIN) | (1 << BTN5_PIN) | (1 << BTN6_PIN) | (1 << BTN7_PIN));
              
    DDRC &= ~((1 << BTN8_PIN) | (1 << BTN9_PIN) | (1 << DECIMAL_BTN_PIN) |
              (1 << OP_BTN_PIN) | (1 << TRIG_BTN_PIN) | (1 << ENTER_BTN_PIN));
              
    PORTD |= ((1 << BTN0_PIN) | (1 << BTN1_PIN) | (1 << BTN2_PIN) | (1 << BTN3_PIN) |
              (1 << BTN4_PIN) | (1 << BTN5_PIN) | (1 << BTN6_PIN) | (1 << BTN7_PIN));
              
    PORTC |= ((1 << BTN8_PIN) | (1 << BTN9_PIN) | (1 << DECIMAL_BTN_PIN) |
              (1 << OP_BTN_PIN) | (1 << TRIG_BTN_PIN) | (1 << ENTER_BTN_PIN));
}

int check_button(volatile uint8_t *pin_reg, uint8_t pin) {
    return !(*pin_reg & (1 << pin)); // Returns true if button is pressed.
}

// Helper functions for expression handling.

void append_char(char c) {
    if (exprIndex < MAX_EXPR_LENGTH - 1) {
        expression[exprIndex++] = c;
        expression[exprIndex] = '\0';
        update_lcd();
    }
}

void update_lcd(void) {
    lcd_cmd(0x01); // Clear display.
    lcd_print(expression); // Print the current expression.
}

void append_operator(void) {
    char operators[] = {'+', '-', '*', '/'};
    
    if (!operatorSelected && exprIndex > 0 && exprIndex < MAX_EXPR_LENGTH - 2) {
        apped_char(operators[operation]);
        operatorSelected = 1;
        trigSelected = 0;
        update_lcd();
    }
}

void append_trig_function(void) {
    const char *trig_funcs[] = {"sin(", "cos(", "tan(", "asin(", "acos(", "atan("};
    
    if ((exprIndex == 0 || operatorSelected || trigSelected)) {
        strcat(expression, trig_funcs[trigMode]);
        exprIndex += strlen(trig_funcs[trigMode]);
        update_lcd();
        
        operatorSelected = 0; // Reset operator flag.
        trigSelected = 1;     // Set trig flag.
    }
}

void process_enter(void) {
    // Placeholder for evaluation logic.
    
    if (!resultDisplayed && exprIndex > 0) {
        lcd_cmd(0x01); // Clear display.
        lcd_print("Result"); // Replace with actual result computation logic.
        
        resultDisplayed = 1; // Mark result as displayed.
        exprIndex = strlen(expression); 
   }
}

// Main function.

int main(void) {
    // Initialize expression
    expression[0] = '\0';
    
    // Initialize LCD
    lcd_init();
    
    // Initialize buttons
    init_buttons();
    
    // Display welcome message
    lcd_print("Enter Expr:");
    
    // Main loop
    while (1) {
        // Check decimal button first, regardless of resultDisplayed state
        if (check_button(&DECIMAL_BTN_PIN_REG, DECIMAL_BTN_PIN)) {
            _delay_ms(200);
            // If result is displayed, start a new expression
            if (resultDisplayed) {
                exprIndex = 0;
                expression[0] = '\0';
                resultDisplayed = 0;
                append_char('0');  // Start with "0." when adding decimal after result
            }
            
            // Check if the current number already has a decimal point
            int hasDecimal = 0;
            int i = exprIndex - 1;
            
            // Go backward until we find an operator or the beginning of the expression
            while (i >= 0) {
                if (expression[i] == '+' || expression[i] == '-' || 
                    expression[i] == '*' || expression[i] == '/' ||
                    expression[i] == '(') {
                    break;
                }
                if (expression[i] == '.') {
                    hasDecimal = 1;
                    break;
                }
                i--;
            }
            
            // Only add decimal if current number doesn't have one
            if (!hasDecimal) {
                // If at the start of expression or after an operator, add a leading zero
                if (exprIndex == 0 || 
                    (exprIndex > 0 && (expression[exprIndex-1] == '+' || 
                                      expression[exprIndex-1] == '-' || 
                                      expression[exprIndex-1] == '*' || 
                                      expression[exprIndex-1] == '/' ||
                                      expression[exprIndex-1] == '('))) {
                    append_char('0');
                }
                
                append_char('.');
                operatorSelected = 0;
                update_lcd();
            }
        }
        
        // Check number buttons (0-9)
        volatile uint8_t* BTN_PIN_REG[] = {&BTN0_PIN_REG, &BTN1_PIN_REG, &BTN2_PIN_REG, &BTN3_PIN_REG,
                                           &BTN4_PIN_REG, &BTN5_PIN_REG, &BTN6_PIN_REG, &BTN7_PIN_REG,
                                           &BTN8_PIN_REG, &BTN9_PIN_REG};
        uint8_t BTN_PIN[] = {BTN0_PIN, BTN1_PIN, BTN2_PIN, BTN3_PIN, BTN4_PIN,
                             BTN5_PIN, BTN6_PIN, BTN7_PIN, BTN8_PIN, BTN9_PIN};
        
        for (int i = 0; i <= 9; i++) {
            if (check_button(BTN_PIN_REG[i], BTN_PIN[i])) {
                _delay_ms(200);
                if (resultDisplayed) {
                    exprIndex = 0;
                    expression[0] = '\0';
                    resultDisplayed = 0;
                }
                append_char('0' + i);
                operatorSelected = 0;
                update_lcd();
            }
        }
        
        // Check operator button
        if (check_button(&OP_BTN_PIN_REG, OP_BTN_PIN)) {
            _delay_ms(200);
            
            // Cycle through operators
            operation = (operation + 1) % OPERATOR_COUNT;
            operatorSelected = 1;
            trigSelected = 0;  // Deselect trig mode when operator pressed
            
            append_operator();
        }
        
        // Check trigonometric function button
        if (check_button(&TRIG_BTN_PIN_REG, TRIG_BTN_PIN)) {
            _delay_ms(200);
            
            // Cycle through trig functions (including inverse)
            trigMode = (trigMode + 1) % TRIG_COUNT;
            trigSelected = 1;
            operatorSelected = 0;  // Deselect operator mode when trig pressed
            
            append_trig_function();
        }
        
        // Check enter button
        if (check_button(&ENTER_BTN_PIN_REG, ENTER_BTN_PIN)) {
            _delay_ms(200);
            
            // Only process if not already showing a result
            if (!resultDisplayed) {
                process_enter();
            }
        }
        
        // Small delay to prevent button bouncing
        _delay_ms(10);
    }
    
    return 0;
}n
