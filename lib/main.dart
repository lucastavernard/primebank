import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(PrimeBank());
}

class PrimeBank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Banco Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.orangeAccent,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          buttonColor: Colors.blueAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TelaLogin(),
        '/principal': (context) => TelaPrincipal(),
        '/cotacao': (context) => TelaCotacao(),
        '/emprestimo': (context) => TelaEmprestimo(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/transferencia') {
          final args = settings.arguments as Function(double);
          return MaterialPageRoute(
            builder: (context) => TelaTransferencia(atualizarSaldo: args),
          );
        } else if (settings.name == '/extrato') {
          final TransferenciaArgs args = settings.arguments as TransferenciaArgs;
          return MaterialPageRoute(
            builder: (context) => TelaComprovante(args: args),
          );
        }
        return null;
      },
    );
  }
}


class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _erroMensagem = '';

  void _entrar() {
    final String usuario = _usuarioController.text;
    final String senha = _senhaController.text;

    if (usuario.isEmpty || senha.isEmpty) {
      setState(() {
        _erroMensagem = 'Por favor, preencha todos os campos.';
      });
    } else {
      setState(() {
        _erroMensagem = '';
      });
      Navigator.pushNamed(context, '/principal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/icone-bitcoin-bleue-logo.png', height: 100),
                SizedBox(height: 30),
                Text(
                  'Bem-vindo ao PRIMEBANK',
                  style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),

                ),
                SizedBox(height: 30),
                TextField(
                  controller: _usuarioController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Usuário',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    child: Text(
                      'Entrar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  onPressed: _entrar,
                ),
                SizedBox(height: 20),
                if (_erroMensagem.isNotEmpty)
                  Text(
                    _erroMensagem,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  double saldo = 1000.00;

  void atualizarSaldo(double valorTransferencia) {
    setState(() {
      saldo -= valorTransferencia;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PRIME BANK', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Saldo: R\$ ${saldo.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: Icon(Icons.attach_money),
                    label: Text('Cotação'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cotacao');
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text('Transferência'),
                    onPressed: () async {
                      final resultado = await Navigator.pushNamed(
                        context,
                        '/transferencia',
                        arguments: atualizarSaldo,
                      );
                      if (resultado != null && resultado is TransferenciaArgs) {
                        Navigator.pushNamed(
                          context,
                          '/extrato',
                          arguments: resultado,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.monetization_on),
                    label: Text('Empréstimo'),
                    onPressed: () async {
                      final resultado = await Navigator.pushNamed(
                        context,
                        '/emprestimo',
                      );
                      if (resultado != null && resultado is double) {
                        setState(() {
                          saldo += resultado;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TelaCotacao extends StatefulWidget {
  @override
  _TelaCotacaoState createState() => _TelaCotacaoState();
}

class _TelaCotacaoState extends State<TelaCotacao> {
  String cotacao = '';
  bool isLoading = false;
  String erro = '';

  Future<void> getCotacao() async {
    setState(() {
      isLoading = true;
      erro = '';
    });

    try {
      final response = await http.get(
          Uri.parse('https://v6.exchangerate-api.com/v6/355e5f5b95951553182889d1/latest/USD')
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          cotacao = jsonResponse['conversion_rates']['BRL'].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          erro = 'Erro ao buscar cotação: Código de status ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao buscar cotação: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCotacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotação', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              CircularProgressIndicator()
            else if (erro.isNotEmpty)
              Text(erro, style: TextStyle(color: Colors.red))
            else
              Text('Valor atual do dólar: $cotacao', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Atualizar Cotação'),
              onPressed: getCotacao,
            ),
          ],
        ),
      ),
    );
  }
}

class TelaTransferencia extends StatefulWidget {
  final Function(double) atualizarSaldo;

  TelaTransferencia({required this.atualizarSaldo});

  @override
  _TelaTransferenciaState createState() => _TelaTransferenciaState();
}

class _TelaTransferenciaState extends State<TelaTransferencia> {
  final TextEditingController _destinatarioController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transferência', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _destinatarioController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Destinatário',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _valorController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Valor da Transferência',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Confirmar Transferência'),
              onPressed: () {
                final String destinatario = _destinatarioController.text;
                final double valor = double.tryParse(_valorController.text) ?? 0.0;
                widget.atualizarSaldo(valor);
                Navigator.pop(
                  context,
                  TransferenciaArgs(destinatario, valor),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TransferenciaArgs {
  final String destinatario;
  final double valor;

  TransferenciaArgs(this.destinatario, this.valor);
}

class TelaEmprestimo extends StatelessWidget {
  final TextEditingController _valorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empréstimo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _valorController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Valor do Empréstimo',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Solicitar Empréstimo'),
              onPressed: () {
                final double valor = double.tryParse(_valorController.text) ?? 0.0;
                Navigator.pop(context, valor);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TelaComprovante extends StatelessWidget {
  final TransferenciaArgs args;

  TelaComprovante({required this.args});

  void compartilharComprovante(BuildContext context) {
    String textoComprovante = 'Transferência para: ${args.destinatario}\nValor: R\$ ${args.valor.toStringAsFixed(2)}';
    Share.share(textoComprovante);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comprovante', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => compartilharComprovante(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Comprovante de Transferência', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            Text('Destinatário: ${args.destinatario}', style: Theme.of(context).textTheme.bodyMedium),
            Text('Valor Transferido: R\$ ${args.valor.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 20),
            Text('Transferência Realizada', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
